terraform {
  backend "s3" {
    bucket         = "seyoawe-terraform-state-bucket-8520"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "seyoawe-terraform-lock"
  }
}
