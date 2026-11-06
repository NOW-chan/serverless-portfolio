# ------------------------------------------------------------
# GitHub Actions を OIDC で認証する
# = アクセスキーを Secrets に置かない。ここが面談での説明ポイント。
# ------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # thumbprint は現在 AWS 側で検証されるため実質任意だが、指定は必要
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  # ※ アカウントに既に OIDC プロバイダーがある場合はこの resource を削除し、
  #    data "aws_iam_openid_connect_provider" に置き換える (重複作成はエラーになる)
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    effect  = "Allow"
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

    # 特定リポジトリの main ブランチと PR のみに限定 (ここを * にしない)
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repo}:ref:refs/heads/main",
        "repo:${var.github_repo}:pull_request",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.project}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

# Terraform を回すロールの権限。
# 理想はさらに絞ることだが、まずは PowerUser + 必要な IAM 操作で運用し、
# 「なぜこの粒度にしたか / 本番ならどう絞るか」を README に書くのが現実解。
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy" "github_actions_iam" {
  name = "${var.project}-tf-iam"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:GetRole", "iam:CreateRole", "iam:DeleteRole", "iam:TagRole",
        "iam:GetRolePolicy", "iam:PutRolePolicy", "iam:DeleteRolePolicy",
        "iam:AttachRolePolicy", "iam:DetachRolePolicy",
        "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole", "iam:PassRole",
        "iam:GetOpenIDConnectProvider"
      ]
      Resource = "*"
    }]
  })
}
