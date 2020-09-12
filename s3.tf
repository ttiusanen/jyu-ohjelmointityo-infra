# Set up S3 bucket for static website hosting
resource "aws_s3_bucket" "issueapp" {
  bucket = var.s3_bucket_name
  acl = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "DELETE"]
    allowed_origins = [var.s3_cors_allowed_origin]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::issueapp/*"
      ]
    }
  ]
}
EOF

  website {
    index_document = "index.html"
  }
}



