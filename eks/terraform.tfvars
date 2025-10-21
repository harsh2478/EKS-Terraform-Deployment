aws-region = "us-east-2"
org_name = "clouOps"
cluster_name                  = "my-eks-cluster"
env                           = "dev"
vpc_cidr_block                = "10.16.0.0/16"
vpc-name                      = "eks-vpc"
igw-name                      = "eks-igw"
pub-subnet-count              = 3
pub-cidr-block                = ["10.16.0.0/20", "10.16.16.0/20", "10.16.32.0/20"]
pub-availability_zone         = ["us-east-2a", "us-east-2b", "us-east-2c"]
pub-subnet-name               = "subnet-public"
public-rt-name                = "public-route-table"
pri-subnet-count              = 3
pri-cidr-block                = ["10.16.128.0/20", "10.16.144.0/20", "10.16.160.0/20"]
pri-availability_zone         = ["us-east-2a", "us-east-2b", "us-east-2c"]
pri-subnet-name               = "subnet-private"
eip-name                      = "elasticip-ngw"
ngw-name                      = "eks-ngw"
private-rt-name               = "private-route-table"
eks-sg                        = "eks-sg"
is_eks_role_enabled           = true
is_eks_nodegroup_role_enabled = true
is-eks-cluster-enabled        = true
cluster-version               = "1.32"
endpoint-private-access       = true
endpoint-public-access        = true
addons = [
  {
    name    = "vpc-cni"
    version = "v1.20.4-eksbuild.1"
  },
  {
    name    = "coredns"
    version = "v1.11.4-eksbuild.22"
  },
  {
    name    = "kube-proxy"
    version = "v1.32.6-eksbuild.8"
  },
  {
    name    = "aws-ebs-csi-driver"
    version = "v1.46.0-eksbuild.1"
  }
]
desired_capacity_on_demand = "1"
min_capacity_on_demand     = "1"
max_capacity_on_demand     = "5"
ondemand_instance_types    = ["t3a.medium"]
desired_capacity_spot      = "1"
min_capacity_spot          = "1"
max_capacity_spot          = "10"
spot_instance_types        = ["c5a.large", "c5a.xlarge", "m5a.large", "m5a.xlarge", "c5.large", "m5.large", "t3a.large", "t3a.xlarge", "t3a.medium"]