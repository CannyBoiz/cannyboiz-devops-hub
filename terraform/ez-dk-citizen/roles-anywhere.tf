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

# preserve the live broad policy during import; remove it after the
# least-privilege managed attachment is applied and verified.
data "aws_iam_policy_document" "legacy_roles_anywhere_s3" {
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.citizenship_audio.arn]
  }

  statement {
    sid    = "ReadWriteObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.citizenship_audio.arn}/*"]
  }
}

resource "aws_iam_role_policy" "legacy_app_s3" {
  name   = "Policy"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.legacy_roles_anywhere_s3.json
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
