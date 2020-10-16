data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# The wafregional resources are for ALBs in an AWS region, if we just used *_waf_* resources it would be in effect for
# Cloudfront

resource "aws_wafregional_web_acl" "app_acl" {
  default_action {
    type = "ALLOW"
  }

  metric_name = "${var.app}webacl${var.env}"
  name        = "${var.app}-web-acl-${var.env}"

  # Here we attach all of the rules we've created to the ACL.  Lower priority values means they will be evaluated first.
  # Valid values for the type in the action block of the rule are: BLOCK, ALLOW, and COUNT.
  rule {
    action {
      type = var.SQLI_ACTION
    }

    priority = 1
    rule_id  = aws_wafregional_rule.sql-inj-rule.id
  }

  rule {
    action {
      type = var.BYTE_MATCH_ACTION
    }

    priority = 2
    rule_id  = aws_wafregional_rule.byte-match-rule.id
  }

  rule {
    action {
      type = var.IP_ACTION
    }
    priority = 3
    rule_id = aws_wafregional_rule.WAFIPRule.id
  }
}

# Associate our WEB ACL with the ALB

resource "aws_wafregional_web_acl_association" "alb-association" {
  resource_arn = var.alb_arn
  web_acl_id   = aws_wafregional_web_acl.app_acl.id
}
