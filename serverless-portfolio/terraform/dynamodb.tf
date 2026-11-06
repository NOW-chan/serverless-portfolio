# ------------------------------------------------------------
# DynamoDB : オンデマンド課金。25GB / 月まで常時無料枠。
# ------------------------------------------------------------
resource "aws_dynamodb_table" "app" {
  name         = "${var.project}-table"
  billing_mode = "PAY_PER_REQUEST" # プロビジョンドは使わなくても課金される
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  # ポートフォリオ用途では PITR 不要 (有効にするとストレージ課金が発生)。
  # 「本番なら有効にする」という判断理由を README に書くこと。
  point_in_time_recovery {
    enabled = false
  }
}
