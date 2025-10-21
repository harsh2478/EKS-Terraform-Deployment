data "aws_iam_policy_document" "eks-oidc-assume-role-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks-oidc.arn]
    }
  }
}

data "tls_certificate" "eks-certificate" {
  url = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}