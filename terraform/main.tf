# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # --- Terraform State Backend (Recommended for production) ---
  # To use this, create an S3 bucket and uncomment the following block.
  # This provides a secure, remote location to store your infrastructure's state.
  #
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket-name" # Replace with your S3 bucket name
  #   key            = "strapi-ecs/terraform.tfstate"
  #   region         = "ap-south-1"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}

# Retrieve information about your pre-existing ECR repository
data "aws_ecr_repository" "strapi_repo" {
  name = var.ecr_repository_name
}
