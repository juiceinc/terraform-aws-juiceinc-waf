variable "env" {
  default = "demoapp"
}

variable "app_name" {
  default = "dev"
}

variable "alb_arn" {
  default     = "arn:aws:elasticloadbalancing:us-east-1:112233445566:loadbalancer/app/demoapp/1b3c652ebf3637"
  description = "If you're not already using a variable to get the ARN you can find the full value in the console."
}
