resource "aws_s3_bucket" "code_bucket" {
  bucket = "lti-project-code-bucket"
}

# resource "aws_s3_bucket_acl" "code_bucket_acl" {
#   bucket = aws_s3_bucket.code_bucket.id
#   acl    = "private"
# }

resource "null_resource" "generate_zip" {
  provisioner "local-exec" {
    command = "sh ../generar-zip.sh"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "aws_s3_object" "backend_zip" {
  bucket = aws_s3_bucket.code_bucket.id
  key    = "backend.zip"
  source = "../backend.zip"
  acl    = "private"
}

resource "aws_s3_object" "frontend_zip" {
  bucket     = aws_s3_bucket.code_bucket.id
  key        = "frontend.zip"
  source     = "../frontend.zip"
  depends_on = [null_resource.generate_zip]
}
