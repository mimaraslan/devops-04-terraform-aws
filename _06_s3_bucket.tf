resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket-adana-ankara-izmir-1453"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
