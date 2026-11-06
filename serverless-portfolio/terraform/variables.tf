variable "project" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "sls-portfolio"
}

variable "region" {
  description = "メインリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "github_repo" {
  description = "OIDC で信頼する GitHub リポジトリ (例: nowchan/serverless-portfolio)"
  type        = string
}

variable "alert_email" {
  description = "アラート通知先メールアドレス"
  type        = string
}

variable "budget_limit_usd" {
  description = "月次予算アラートのしきい値 (USD)"
  type        = string
  default     = "5"
}

variable "log_retention_days" {
  description = "CloudWatch Logs の保持日数。無期限にすると地味に課金が積み上がるので必ず設定する"
  type        = number
  default     = 7
}
