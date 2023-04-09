// https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  oidc_provider  = replace(module.k8s.eks_cluster_identity_oidc_issuer, "/(https://)/", "")
}

resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  version    = "2.17.2"
  chart      = "aws-ebs-csi-driver"
  values = [
    <<EOF
      controller:
        nodeSelector:
          ${local.node_pool_label_key}: ${local.system_node_pool}
        serviceAccount:
          create: true
          name: ebs-csi-controller-sa
          annotations:
            eks.amazonaws.com/role-arn: ${aws_iam_role.ebs_csi_driver.arn}
    EOF
  ]
}

resource "aws_iam_role" "ebs_csi_driver" {
  name = "${local.name}-ebs-csi"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.aws_account_id}:oidc-provider/${local.oidc_provider}"
        }
        Action = [
          "sts:AssumeRoleWithWebIdentity"
        ]
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:aud" : "sts.amazonaws.com"
            "${local.oidc_provider}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      },
    ]
  })
}

data "aws_iam_policy" "ebs_csi_driver_policy" {
  # This is a managed policy that already exists.
  # https://docs.aws.amazon.com/eks/latest/userguide/security-iam-awsmanpol.html
  name = "AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = data.aws_iam_policy.ebs_csi_driver_policy.arn
}
