resource "aws_s3_bucket" "code_bucket" {
  bucket = "lti-project-code-bucket-jlso"
}

resource "aws_s3_bucket_ownership_controls" "code_bucket_ownership" {
  bucket = aws_s3_bucket.code_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "null_resource" "generate_zip" {
  provisioner "local-exec" {
    command = "sh ../generar-zip.sh"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "aws_s3_object" "backend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "backend.zip"
  source     = "../backend.zip"
  depends_on = [null_resource.generate_zip, aws_s3_bucket.code_bucket, aws_s3_bucket_ownership_controls.code_bucket_ownership]
}

resource "aws_s3_object" "frontend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "frontend.zip"
  source     = "../frontend.zip"
  depends_on = [null_resource.generate_zip, aws_s3_bucket.code_bucket, aws_s3_bucket_ownership_controls.code_bucket_ownership]
}
