resource "aws_s3_bucket" "bucket" {
  bucket = "my-alb-test-bucket-logs"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "test-logs/AWSLogs/acct-id/"
}

resource "aws_s3_account_public_access_block" "example" {
  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    id = "log"

    expiration {
      days = 30
    }

    filter {
      and {
        prefix = "test-logs/"

        tags = {
          rule      = "log"
          autoclean = "true"
        }
      }
    }

    status = "Enabled"
  }
}

data "aws_iam_policy_document" "allow_elb_logs" {
  statement {
    sid = "AWSConsoleStmt-1660163243880"
    principals {
      type        = "AWS"
      identifiers = ["127311923021"]
    }
    actions = [
        "s3:PutObject",
    ]
    resources = [
        "${aws_s3_bucket.bucket.arn}/test-logs/AWSLogs/acct-id/*",
    ]
  }
  statement {
    sid = "AWSLogDeliveryWrite"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
        "s3:PutObject",
    ]
    resources = [
        "${aws_s3_bucket.bucket.arn}/test-logs/AWSLogs/acct-id/*",
    ]
    condition {
        test = "StringEquals"
        variable = "s3:x-amz-acl"
        values = [
            "bucket-owner-full-control",
        ]
    }
  }
  statement {
    sid = "AWSLogDeliveryAclCheck"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
        "s3:GetBucketAcl",
    ]
    resources = [
        "${aws_s3_bucket.bucket.arn}",
    ]
  }  
}


resource "aws_s3_bucket_policy" "allow_access_from_elb" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_elb_logs.json
}



