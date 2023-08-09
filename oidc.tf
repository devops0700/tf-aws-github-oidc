resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enabled && var.create_oidc_provider ? 1 : 0
    
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
    "6938fd4d98bab03faadb97b34396831e3780aea1"
    ]
  url             = "https://token.actions.githubusercontent.com"
}

/* # Redundant code
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
} */


resource "aws_iam_role" "github_actions" {
  name               = "github-actions-ecr-push"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy.json
}

/* # Redundant
resource "aws_iam_role" "github_actions" {
  name               = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
} */

/* resource "aws_iam_openid_connect_provider" "github" {
  count = var.enabled && var.create_oidc_provider ? 1 : 0

  client_id_list = concat(
    [for org in local.github_organizations : "https://github.com/${org}"],
    ["sts.amazonaws.com"]
  )

  tags = var.tags
  url  = "https://token.actions.githubusercontent.com%{if var.enterprise_slug != ""}/${var.enterprise_slug}%{endif}"
  thumbprint_list = toset(var.additional_thumbprints != null ?
    concat(
      local.known_thumbprints,
      [data.tls_certificate.github.certificates[0].sha1_fingerprint],
      var.additional_thumbprints,
    ) :
    concat(
      local.known_thumbprints,
      [data.tls_certificate.github.certificates[0].sha1_fingerprint],
    )
  )
} */

resource "aws_iam_role_policy" "github_actions" {
  name   = "github-actions-ecr-push"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions.json
}

/* # Redundant
resource "aws_iam_policy" "github_actions" {
  name        = "github-actions"
  description = "Grant Github Actions the ability to push to ECR"
  policy      = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
} */

resource "aws_ecr_repository" "repo" {
  name                 = "oidc/tf-aws-github-oidc"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    "permit-github-action" = true
  }
}