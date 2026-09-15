resource "aws_s3_bucket" "citizenship_audio" {
  bucket = "ez-dk-citizen-audio"

  tags = {
    project     = "ez-dk-citizen"
    environment = "production"
  }
}

resource "aws_s3_bucket_public_access_block" "citizenship_audio" {
  bucket = aws_s3_bucket.citizenship_audio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "citizenship_audio" {
  bucket = aws_s3_bucket.citizenship_audio.id

  cors_rule {
    allowed_headers = ["content-type", "if-none-match"]
    allowed_methods = ["PUT"]
    allowed_origins = compact([
      var.admin_local_origin,
      var.admin_production_origin,
    ])
  }
}

data "aws_iam_policy_document" "citizenship_audio" {
  statement {
    sid    = "DenyWritesWithoutIfNoneMatch"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.citizenship_audio.arn}/*"]

    condition {
      test     = "Null"
      variable = "s3:if-none-match"
      values   = ["true"]
    }
  }

  statement {
    sid    = "DenyWritesWithoutIfNoneMatchStar"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.citizenship_audio.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:if-none-match"
      values   = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "citizenship_audio" {
  bucket = aws_s3_bucket.citizenship_audio.id
  policy = data.aws_iam_policy_document.citizenship_audio.json
}

resource "aws_s3_bucket_versioning" "citizenship_audio" {
  bucket = aws_s3_bucket.citizenship_audio.id

  versioning_configuration {
    status = "Suspended"
  }
}
