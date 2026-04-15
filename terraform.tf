terraform {
    backend "s3" {
        bucket = "dunjee-terraform-bucket"
        key = "path/to/my/key"
        region = "eu-west-2"
    }

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.40.0"
        }
    }
}
