terraform {
  backend "s3" {
    bucket = "terraform-github-backend"
    key    = "backend/terraform.tfstate"
    region = "us-east-1"
  }
}
