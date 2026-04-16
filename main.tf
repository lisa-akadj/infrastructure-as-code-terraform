provider "aws" {
    region = "eu-west-2"
}

terraform {
    backend "s3" {
        bucket = "dunjee-terraform-bucket"
        key = "terraform.tfstate"
        region = "eu-west-2"
    }
}

resource "aws_ecr_repository" "dunjee_repo" {
    name = "dunjee_terraform_ecr"
    image_tag_mutability = "MUTABLE"
}