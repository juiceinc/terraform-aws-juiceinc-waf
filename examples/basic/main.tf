provider "aws" {
  region  = "us-east-1"
  version = "~> 1.30.0"
}

module "waf" {
  source  = "git@github.com:juiceinc/terraform-aws-juiceinc-waf.git?ref=v0.1.0"
  env     = "${var.env}"
  app     = "${var.app_name}"
  alb_arn = "${var.alb_arn}"
}
