resource "aws_iam_user" "rancher_eks" {
  name = "rancher_eks"
  path = "/"

  tags = {
    purpose = "manage EKS clusters via Rancher"
  }
}

resource "aws_iam_policy_attachment" "rancher_eks" {
  name       = "rancher_eks"
  users      = [aws_iam_user.rancher_eks.name]
  policy_arn = aws_iam_policy.rancher_eks.arn
}

resource "aws_iam_policy_attachment" "rancher_eks_service_role" {
  name       = "rancher_eks_service_role"
  users      = [aws_iam_user.rancher_eks.name]
  policy_arn = aws_iam_policy.rancher_eks_service_role.arn
}

resource "aws_iam_access_key" "rancher_eks" {
  user = aws_iam_user.rancher_eks.name
}

resource "aws_secretsmanager_secret" "rancher_eks" {
  name = "rancher_eks-${random_string.random.result}"
}

resource "aws_secretsmanager_secret_version" "rancher_eks" {
  secret_id = aws_secretsmanager_secret.rancher_eks.id
  secret_string = jsonencode({
    id     = aws_iam_access_key.rancher_eks.id,
    secret = aws_iam_access_key.rancher_eks.secret
  })
}

resource "rancher2_cloud_credential" "manage_eks_permissions" {
  provider = rancher2.admin
  
  name = "eks"
  description = "iam user with permissions to manage eks"
  amazonec2_credential_config {
    access_key = aws_iam_access_key.rancher_eks.id
    secret_key = aws_iam_access_key.rancher_eks.secret
  }
}