resource "aws_s3_bucket" "citizenship_audio" {
  bucket = "ez-dk-citizen-audio"

  tags = {
    project = "ez-dk-citizen"
    environment = "production" 
  }
}