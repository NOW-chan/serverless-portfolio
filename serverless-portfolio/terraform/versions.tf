terraform {
  required_version = ">= 1.10"

  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.60" }
    archive = { source = "hashicorp/archive", version = "~> 2.4" }
  }

  # 【手順】初回は local state で apply する。
  # tfstate 保管用の S3 バケットを作った後に、以下のコメントを外して
  # `terraform init -migrate-state` を実行する。
  # Terraform 1.10+ の use_lockfile を使うと、ロック用の DynamoDB テーブルが不要になる。
  #
  # backend "s3" {
  #   bucket       = "CHANGE-ME-tfstate-xxxxxx"
  #   key          = "serverless-portfolio/terraform.tfstate"
  #   region       = "ap-northeast-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "Terraform"
    }
  }
}
