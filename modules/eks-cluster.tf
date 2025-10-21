resource "aws_eks_cluster" "eks" {
  count    = var.is-eks-cluster-enabled == true ? 1 : 0
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-role[count.index].arn
  version  = var.cluster-version

  vpc_config {
    subnet_ids              = [aws_subnet.pri-subnet[0].id, aws_subnet.pri-subnet[1].id, aws_subnet.pri-subnet[2].id]
    endpoint_private_access = var.endpoint-private-access
    endpoint_public_access  = var.endpoint-public-access
    security_group_ids      = [aws_security_group.eks-cluster-sg.id]
  }

  access_config {
    authentication_mode                         = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name = var.cluster_name
    Env  = var.env
  }

  depends_on = [ aws_iam_role.eks-cluster-role, aws_iam_role_policy_attachment.AmazonEKSClusterPolicy ]
}

resource "aws_iam_openid_connect_provider" "eks-oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-certificate.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks-certificate.url
}

resource "aws_eks_node_group" "ondemand-node" {
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-ondemand-nodes"
  node_role_arn   = aws_iam_role.eks-nodegroup-role[0].arn
  scaling_config {
    desired_size = var.desired_capacity_on_demand
    min_size     = var.min_capacity_on_demand
    max_size     = var.max_capacity_on_demand
  }

  subnet_ids     = [aws_subnet.pri-subnet[0].id, aws_subnet.pri-subnet[1].id, aws_subnet.pri-subnet[2].id]
  instance_types = var.ondemand_instance_types
  capacity_type  = "ON_DEMAND"
  labels = {
    type = "ondemand"
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.cluster_name}-ondemand-nodes"
  }

  tags_all = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    Name                                        = "${var.cluster_name}-ondemand-nodes"
  }

  depends_on = [aws_eks_cluster.eks]
}


resource "aws_eks_node_group" "spot-node" {
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-spot-nodes"
  node_role_arn   = aws_iam_role.eks-nodegroup-role[0].arn
  scaling_config {
    desired_size = var.desired_capacity_spot
    min_size     = var.min_capacity_spot
    max_size     = var.max_capacity_spot
  }

  subnet_ids     = [aws_subnet.pri-subnet[0].id, aws_subnet.pri-subnet[1].id, aws_subnet.pri-subnet[2].id]
  instance_types = var.spot_instance_types
  capacity_type  = "SPOT"
  labels = {
    type      = "spot"
    lifecycle = "spot"
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.cluster_name}-spot-nodes"
  }
  tags_all = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    Name                                        = "${var.cluster_name}-spot-nodes"
  }

  disk_size  = 50
  depends_on = [aws_eks_cluster.eks]
}

resource "aws_eks_addon" "eks-addons" {
  for_each      = { for idx, addon in var.addons : idx => addon }
  cluster_name  = aws_eks_cluster.eks[0].name
  addon_name    = each.value.name
  addon_version = each.value.version
  depends_on    = [aws_eks_node_group.ondemand-node, aws_eks_node_group.spot-node]
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks[0].endpoint
}

resource "null_resource" "update-Kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.aws-region} update-kubeconfig --name ${var.cluster_name}"
  }
  depends_on = [ aws_eks_cluster.eks, aws_eks_node_group.ondemand-node, aws_eks_node_group.spot-node ]
}