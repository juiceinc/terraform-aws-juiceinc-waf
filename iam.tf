resource "aws_iam_role" "WAFReputationUpdater" {
  name               = "WAFReputationRole"
  assume_role_policy = "${data.aws_iam_policy_document.WAFReputationAssumeRolePolicy.json}"
}

data "aws_iam_policy_document" "WAFReputationAssumeRolePolicy" {
  statement {
    sid     = "AllowBaseAccountToAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "WAFLambdaPermissions" {
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"]
  }

  statement {
    sid       = "CloudWatchMetricAccess"
    effect    = "Allow"
    actions   = ["cloudwatch:GetMetricStatistics"]
    resources = ["*"]
  }

  statement {
    sid       = "WAFGetChangeToken"
    effect    = "Allow"
    actions   = ["waf-regional:GetChangeToken"]
    resources = ["*"]
  }

  statement {
    sid    = "WAFGetAndUpdateIPSet"
    effect = "Allow"

    actions = [
      "waf-regional:GetIPSet",
      "waf-regional:UpdateIPSet",
    ]

    resources = [
      "${aws_wafregional_ipset.WAFIPSet1.arn}",
      "${aws_wafregional_ipset.WAFIPSet2.arn}"
    ]
  }

  statement {
    sid    = "WAFAccess"
    effect = "Allow"

    actions = [
      "waf-regional:GetWebACL",
      "waf-regional:UpdateWebACL",
    ]

    resources = [
      "arn:aws:waf-regional:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:webacl/${aws_wafregional_web_acl.app_acl.id}",
    ]
  }

  statement {
    sid       = "LambdaAccess"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "WAFPolicy" {
  name   = "WAFUpdaterPolicy"
  policy = "${data.aws_iam_policy_document.WAFLambdaPermissions.json}"
}

resource "aws_iam_role_policy_attachment" "WAFPolicyAttachment" {
  policy_arn = "${aws_iam_policy.WAFPolicy.arn}"
  role       = "${aws_iam_role.WAFReputationUpdater.name}"
}

resource "aws_lambda_permission" "AllowInvokeFromCloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.WAFIPLambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.InvokeWAFIPLambda.arn}"
}
