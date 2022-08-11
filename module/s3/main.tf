
resource "aws_s3_bucket" "bucket" {
  bucket = format("%s-%s", var.bucket_name, var.ENV)
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = format("ELB-logs/AWSLogs/%s/", var.account_number)
}

resource "aws_s3_bucket_public_access_block" "s3_block_public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    id = var.bucket_rule_id  

    expiration {
      days = var.bucket_rule_expiration_days  
    }

    filter {
      and {
        prefix = var.bucket_rule_prefix  

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
        format("${aws_s3_bucket.bucket.arn}/ELB-logs/AWSLogs/%s/*", var.account_number),           
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
         format("${aws_s3_bucket.bucket.arn}/ELB-logs/AWSLogs/%s/*", var.account_number), 
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