variable "aws-region" {}
variable "cluster_name" {}
variable "vpc_cidr_block" {}
variable "vpc-name" {}
variable "env" {}
variable "igw-name" {}
variable "pub-subnet-count" {}
variable "pub-cidr-block" { type = list(string) }
variable "pub-availability_zone" { type = list(string) }
variable "pub-subnet-name" {}
variable "public-rt-name" {}
variable "pri-subnet-count" {}
variable "pri-cidr-block" { type = list(string) }
variable "pri-availability_zone" { type = list(string) }
variable "pri-subnet-name" {}
variable "eip-name" {}
variable "ngw-name" {}
variable "private-rt-name" {}
variable "eks-sg" {}
variable "is_eks_role_enabled" {}
variable "is_eks_nodegroup_role_enabled" {}
variable "is-eks-cluster-enabled" {}
variable "cluster-version" {}
variable "endpoint-private-access" {}
variable "endpoint-public-access" {}
variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}
variable "desired_capacity_on_demand" {}
variable "min_capacity_on_demand" {}
variable "max_capacity_on_demand" {}
variable "ondemand_instance_types" {}
variable "desired_capacity_spot" {}
variable "min_capacity_spot" {}
variable "max_capacity_spot" {}
variable "spot_instance_types" {}