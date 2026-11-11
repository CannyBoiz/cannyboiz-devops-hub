# State for this module is local and Git-ignored, so a fresh checkout starts
# with none. These blocks adopt the live resources instead of recreating them;
# they are no-ops once the resources are in state.

data "aws_caller_identity" "current" {}

locals {
  app_s3_policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ez-dk-citizen-s3-access"
}

import {
  to = aws_s3_bucket.citizenship_audio
  id = "ez-dk-citizen-audio"
}

import {
  to = aws_s3_bucket_public_access_block.citizenship_audio
  id = "ez-dk-citizen-audio"
}

import {
  to = aws_s3_bucket_cors_configuration.citizenship_audio
  id = "ez-dk-citizen-audio"
}

import {
  to = aws_s3_bucket_policy.citizenship_audio
  id = "ez-dk-citizen-audio"
}

import {
  to = aws_s3_bucket_versioning.citizenship_audio
  id = "ez-dk-citizen-audio"
}

import {
  to = aws_iam_policy.app_s3
  id = local.app_s3_policy_arn
}

import {
  to = aws_iam_role.app
  id = "ez-dk-citizen-role-anywhere-s3"
}

import {
  to = aws_iam_role_policy_attachment.app_s3
  id = "ez-dk-citizen-role-anywhere-s3/${local.app_s3_policy_arn}"
}

import {
  to = aws_rolesanywhere_trust_anchor.app
  id = "f133c1c7-1c50-4786-8352-4dc7c1594393"
}

import {
  to = aws_rolesanywhere_profile.app
  id = "a95bf67d-fdb5-46b9-b7cc-f609acc556d2"
}
