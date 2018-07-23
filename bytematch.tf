# Define our string matching requirements.  In this case check for anything that has .php in the URI (because of
# probing requests)
resource "aws_wafregional_byte_match_set" "byte-match-set" {
  name = "${var.app}bytematchrule${var.env}"

  byte_match_tuple {
    field_to_match {
      type = "URI"
    }

    positional_constraint = "CONTAINS"
    text_transformation   = "NONE"
    target_string         = ".php"
  }
}

# Assign our matching filter above to an actual rule.
resource "aws_wafregional_rule" "byte-match-rule" {
  name        = "byte-match-rule-${var.env}"
  metric_name = "bytematchrule${var.env}"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.byte-match-set.id}"
    negated = false
    type    = "ByteMatch"
  }
}
