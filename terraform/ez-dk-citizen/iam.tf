resource "aws_iam_user" "app" {
  name = "ez-dk-citizen-app"
}

data "aws_iam_policy_document" "app_s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.citizenship_audio.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "app_s3" {
  name = "ez-dk-citizen-s3-access"
  description = "Allow ez-dk-citizen backend to access audio objects"

  policy = data.aws_iam_policy_document.app_s3.json
}

resource "aws_iam_user_policy_attachment" "name" {
  user = aws_iam_user.app.name
  policy_arn = aws_iam_policy.app_s3.arn
}