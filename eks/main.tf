locals {
  org = var.org_name
}

module "eks" {
  source = "../modules"

  cluster_name                  = "${var.env}-${local.org}-${var.cluster_name}"
  aws-region                    = var.aws-region
  env                           = var.env
  vpc_cidr_block                = var.vpc_cidr_block
  vpc-name                      = "${var.env}-${local.org}-${var.vpc-name}"
  igw-name                      = "${var.env}-${local.org}-${var.igw-name}"
  pub-subnet-count              = var.pub-subnet-count
  pub-cidr-block                = var.pub-cidr-block
  pub-availability_zone         = var.pub-availability_zone
  pub-subnet-name               = "${var.env}-${local.org}-${var.pub-subnet-name}"
  public-rt-name                = "${var.env}-${local.org}-${var.public-rt-name}"
  pri-subnet-count              = var.pri-subnet-count
  pri-cidr-block                = var.pri-cidr-block
  pri-availability_zone         = var.pri-availability_zone
  pri-subnet-name               = "${var.env}-${local.org}-${var.pri-subnet-name}"
  eip-name                      = "${var.env}-${local.org}-${var.eip-name}"
  ngw-name                      = "${var.env}-${local.org}-${var.ngw-name}"
  private-rt-name               = "${var.env}-${local.org}-${var.private-rt-name}"
  eks-sg                        = var.eks-sg
  is_eks_role_enabled           = var.is_eks_role_enabled
  is_eks_nodegroup_role_enabled = var.is_eks_nodegroup_role_enabled
  is-eks-cluster-enabled        = var.is-eks-cluster-enabled
  cluster-version               = var.cluster-version
  endpoint-private-access       = var.endpoint-private-access
  endpoint-public-access        = var.endpoint-public-access
  addons                        = var.addons
  desired_capacity_on_demand    = var.desired_capacity_on_demand
  min_capacity_on_demand        = var.min_capacity_on_demand
  max_capacity_on_demand        = var.max_capacity_on_demand
  ondemand_instance_types       = var.ondemand_instance_types
  desired_capacity_spot         = var.desired_capacity_spot
  min_capacity_spot             = var.min_capacity_spot
  max_capacity_spot             = var.max_capacity_spot
  spot_instance_types           = var.spot_instance_types
}

