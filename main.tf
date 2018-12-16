terraform {
  backend "s3" {
    bucket = "danhatesnumbers-cv-infra-tf-state"
    key    = "state.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
    region = "${var.aws_region}"
}

data "aws_iam_policy_document" "state-bucket-policy" {
  statement {
    sid = "ensure-private-read-write"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["arn:aws:s3:::danhatesnumbers-cv-infra-tf-state/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "public-read",
        "public-read-write",
      ]
    }
  }
}

resource "aws_s3_bucket" "state-bucket" {
  bucket = "danhatesnumbers-cv-infra-tf-state"
  acl    = "private"
  policy = "${data.aws_iam_policy_document.state-bucket-policy.json}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    abort_incomplete_multipart_upload_days = 14

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days = 365
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}