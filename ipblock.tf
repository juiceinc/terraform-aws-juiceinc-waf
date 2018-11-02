resource "aws_lambda_function" "WAFIPLambda" {
  filename         = "${path.module}/WAFIPLambda.zip"
  function_name    = "WAFIPLambda"
  role             = "${aws_iam_role.WAFReputationUpdater.arn}"
  handler          = "index.handler"
  source_code_hash = "${base64sha256(file("${path.module}/WAFIPLambda.zip"))}"
  runtime          = "nodejs6.10"
  timeout          = 300
}

resource "aws_cloudwatch_event_target" "WAFIPUpdaterEventTarget" {
  arn  = "${aws_lambda_function.WAFIPLambda.arn}"
  rule = "${aws_cloudwatch_event_rule.InvokeWAFIPLambda.name}"

  input = <<EOF
{
  "lists": [
    {
      "url": "https://www.spamhaus.org/drop/drop.txt"
    },
    {
      "url": "https://check.torproject.org/exit-addresses",
      "prefix": "ExitAddress "
    },
    {
      "url": "https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt"
    }
  ],
  "logType": "alb",
  "region": "${data.aws_region.current.name}",
  "ipSetIds": [
    "${aws_wafregional_ipset.WAFIPSet1.id}",
    "${aws_wafregional_ipset.WAFIPSet2.id}"
  ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "InvokeWAFIPLambda" {
  name                = "InvokeWAFIPUpdater"
  schedule_expression = "rate(1 hour)"
}

resource "aws_wafregional_ipset" "WAFIPWhiteList" {
  name = "IP Reputation Lists Whitelist"
}

resource "aws_wafregional_ipset" "WAFIPSet1" {
  name = "IP Reputation Lists Set #1"
  lifecycle {
    ignore_changes = ["ip_set_descriptor"]
  }
  #Since the lambda dynamically updates the IPSets hourly, and we also don't want those values to necessarily be stored
  # in the state, we want to ignore ip_set_descriptor changes to avoid seeing any large diffs for IPs.
}

resource "aws_wafregional_ipset" "WAFIPSet2" {
  name = "IP Reputation Lists Set #2"
  lifecycle {
    ignore_changes = ["ip_set_descriptor"]
  }
}

resource "aws_wafregional_rule" "WAFIPRule" {
  name        = "WAFIPRule-${var.env}"
  metric_name = "WAFIPRule"

  predicate {
    type    = "IPMatch"
    data_id = "${aws_wafregional_ipset.WAFIPSet1.id}"
    negated = false
  }

  predicate {
    type    = "IPMatch"
    data_id = "${aws_wafregional_ipset.WAFIPSet2.id}"
    negated = false
  }
}