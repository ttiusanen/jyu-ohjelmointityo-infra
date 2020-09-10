# Set up S3 bucket for static website hosting
resource "aws_s3_bucket" "issueapp" {
  bucket = var.s3_bucket_name
  acl = "public-read"
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



