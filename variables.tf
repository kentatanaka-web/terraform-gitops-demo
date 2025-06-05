variable "aws_region" {
  description = "AWS リージョン名"
  type        = string
  default     = "ap-northeast-1"
}

variable "ec2_key_name" {
  description = "EC2 インスタンス用のキーペア名"
  type        = string
}
