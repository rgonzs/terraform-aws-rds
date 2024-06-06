data "aws_caller_identity" "current" {}

resource "aws_kms_key" "s3_cypher_key" {
  description              = "KMS Key used to cipher objects"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  deletion_window_in_days  = 7
  multi_region             = false
  tags                     = var.tags
}

resource "aws_kms_alias" "s3_cypher_key" {
  name          = "alias/s3_cypher_key"
  target_key_id = aws_kms_key.s3_cypher_key.key_id
}

resource "aws_kms_key_policy" "s3_key_policy" {
  key_id = aws_kms_key.s3_cypher_key.id
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-default-1",
    Statement = [
      {
        Sid    = "Allow IAM admin access",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/iamadmin"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_cypher_key.arn
    }
    bucket_key_enabled = true
  }
}

data "aws_iam_policy_document" "s3_iam_admin_access" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/iamadmin"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }

  statement {
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/iamadmin"]

    }

  }
}

resource "aws_s3_bucket_policy" "bucket_policy_iamadmin" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.s3_iam_admin_access.json
}
