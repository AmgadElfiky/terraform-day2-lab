terraform {
  backend "s3" {
    bucket = "terraform-bucket1122"
    key    = "dev/statefil"
    region = "us-east-1"
  }
}