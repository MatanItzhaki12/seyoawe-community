terraform {
  backend "s3" {
    bucket         = "seyoawe-terraform-state-bucket-8520"
    key            = "eks/terraform.tfstate"
    encrypt        = true
    use_lockfile   = true
  }
}
