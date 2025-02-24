resource "aws_s3_bucket" "code_bucket" {
  bucket = "lti-project-code-bucket-${random_string.suffix.result}"
  force_destroy = true

  tags = {
    Name        = "LTI Project Code Bucket"
    Environment = "Dev"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
