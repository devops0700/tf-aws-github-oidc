data "aws_caller_identity" "current" {}

/* data "aws_caller_identity" "source" {} */


data "aws_iam_policy_document" "github_actions_assume_role_policy" {

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        format(
          "arn:aws:iam::%s:oidc-provider/token.actions.githubusercontent.com",
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      #values   = ["repo:ismailyenigul/myrepo:*"]
      values   = [
        "repo:devops0700/tf-aws-github-oidc:*",
        "repo:devops0700/oidc-aws-auth:*"
        ]
    }   
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# https://dev.to/mmiranda/github-actions-authenticating-on-aws-using-oidc-3d2n
/* data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:org1/*:*",
        "repo:org2/*:*"
      ]
    }
  } */

data "aws_iam_policy_document" "github_actions" {

  # docker login to ECR access
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  # ECR push only access
  statement {
    actions = [
      "ecr:BatchGetImage",  
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [format("arn:aws:ecr:%s:%s:repository/*", var.region, data.aws_caller_identity.current.account_id)]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/permit-github-action"

      values = ["true"]
    }    
  }

    # 
  statement {
    actions = [
      "sts:*",  
      "s3:*",
    ]
    resources = ["*"] 
  }
}

/* # Redundant
data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/permit-github-action"

      values = ["true"]
    }
  }
}   */


data "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enabled && !var.create_oidc_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com%{if var.enterprise_slug != ""}/${var.enterprise_slug}%{endif}"
}

/* data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}  */