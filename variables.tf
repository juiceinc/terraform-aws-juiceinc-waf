variable "env" {
  description = "The environment name."
}

variable "app" {
  description = "The app name."
}

variable "alb_arn" {
  description = "The ARN for the Application Load Balancer to associate the WAF ACL with."
}

variable "runtime"{
  default = "nodejs10.x"
}