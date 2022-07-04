resource "aws_iam_policy" "rancher_eks" {
  name        = "rancher_eks_permissions"
  path        = "/"
  description = "rancher eks management required permissions"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2Permisssions",
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:DescribeRegions",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeVpcs",
                "ec2:DescribeTags",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeRouteTables",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeImages",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeAccountAttributes",
                "ec2:DeleteTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteKeyPair",
                "ec2:CreateTags",
                "ec2:CreateSecurityGroup",
                "ec2:CreateLaunchTemplateVersion",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateKeyPair",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CloudFormationPermisssions",
            "Effect": "Allow",
            "Action": [
                "cloudformation:ListStacks",
                "cloudformation:ListStackResources",
                "cloudformation:DescribeStacks",
                "cloudformation:DescribeStackResources",
                "cloudformation:DescribeStackResource",
                "cloudformation:DeleteStack",
                "cloudformation:CreateStackSet",
                "cloudformation:CreateStack"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMPermissions",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "iam:ListRoles",
                "iam:ListRoleTags",
                "iam:ListInstanceProfilesForRole",
                "iam:ListInstanceProfiles",
                "iam:ListAttachedRolePolicies",
                "iam:GetRole",
                "iam:GetInstanceProfile",
                "iam:DetachRolePolicy",
                "iam:DeleteRole",
                "iam:CreateRole",
                "iam:AttachRolePolicy"
            ],
            "Resource": "*"
        },
        {
            "Sid": "KMSPermisssions",
            "Effect": "Allow",
            "Action": "kms:ListKeys",
            "Resource": "*"
        },
        {
            "Sid": "EKSPermisssions",
            "Effect": "Allow",
            "Action": [
                "eks:UpdateNodegroupVersion",
                "eks:UpdateNodegroupConfig",
                "eks:UpdateClusterVersion",
                "eks:UpdateClusterConfig",
                "eks:UntagResource",
                "eks:TagResource",
                "eks:ListUpdates",
                "eks:ListTagsForResource",
                "eks:ListNodegroups",
                "eks:ListFargateProfiles",
                "eks:ListClusters",
                "eks:DescribeUpdate",
                "eks:DescribeNodegroup",
                "eks:DescribeFargateProfile",
                "eks:DescribeCluster",
                "eks:DeleteNodegroup",
                "eks:DeleteFargateProfile",
                "eks:DeleteCluster",
                "eks:CreateNodegroup",
                "eks:CreateFargateProfile",
                "eks:CreateCluster"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "rancher_eks_service_role" {
  name        = "rancher_eks_permissions_service_role"
  path        = "/"
  description = "rancher eks management service role required permissions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IAMPermisssions",
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:AttachRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:CreateRole",
        "iam:CreateServiceLinkedRole",
        "iam:DeleteInstanceProfile",
        "iam:DeleteRole",
        "iam:DetachRolePolicy",
        "iam:GetInstanceProfile",
        "iam:GetRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfiles",
        "iam:ListInstanceProfilesForRole",
        "iam:ListRoles",
        "iam:ListRoleTags",
        "iam:PassRole",
        "iam:RemoveRoleFromInstanceProfile"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}