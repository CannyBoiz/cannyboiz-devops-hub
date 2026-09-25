resource "aws_rolesanywhere_trust_anchor" "app" {
  name    = "my-first-iam-role-anywhere"
  enabled = true

  source {
    source_data {
      x509_certificate_data = file("${path.module}/certs/ca.crt")
    }

    source_type = "CERTIFICATE_BUNDLE"
  }
}

data "aws_iam_policy_document" "roles_anywhere_assume_role" {
  statement {
    sid    = "Statement1"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rolesanywhere.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:SetSourceIdentity",
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_rolesanywhere_trust_anchor.app.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/x509Subject/CN"
      values   = ["aws-iam-app"]
    }
  }
}

resource "aws_iam_role" "app" {
  name                 = "ez-dk-citizen-role-anywhere-s3"
  description          = "IAM role anywhere used for ez-dk-citizen's S3"
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.roles_anywhere_assume_role.json
}

resource "aws_iam_role_policy_attachment" "app_s3" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app_s3.arn
}

resource "aws_rolesanywhere_profile" "app" {
  name                     = "ez-dk-citizen-prod"
  enabled                  = true
  duration_seconds         = 3600
  accept_role_session_name = false
  role_arns                = [aws_iam_role.app.arn]
}
