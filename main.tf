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

resource "aws_elastic_beanstalk_application" "example_app" {
  name        = "dunjee-task-listing-app"
  description = "Task listing app"
}

resource "aws_elastic_beanstalk_environment" "example_app_environment" {
  name                = "dunjee-task-listing-app-environment"
  application         = aws_elastic_beanstalk_application.example_app.name

  # This page lists the supported platforms
  # we can use for this argument:
  # https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html#platforms-supported.docker
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.1 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.example_app_ec2_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "your-ec2-key-pair-name"
  }
}

resource "aws_iam_instance_profile" "example_app_ec2_instance_profile" {
  name = "example-app-instance-profile"
  role = aws_iam_role.example_app_ec2_role.name
}

resource "aws_iam_role" "example_app_ec2_role" {
  name = "example-app-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Essential managed policies for Beanstalk to function
resource "aws_iam_role_policy_attachment" "beanstalk_web_tier" {
  role       = aws_iam_role.example_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}