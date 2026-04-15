terraform {
  backend "s3" {
    bucket         = "seyoawe-terraform-state-bucket-8520"
    key            = "eks/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    use_lockfile   = true
  }
}
