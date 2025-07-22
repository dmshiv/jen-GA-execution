// GA needs to know where the ALBs are located, so we need to define providers for each region.


## need to provide aws providers and region on every folder else tf does not know where to apply 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1" # ✅ Use any valid region like ap-south-1, us-east-1, etc.
}


# Providers for both regions
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}


# accele .tf needs state files of mumbai ,ireland where r they ? on s3 so give them that location  

data "terraform_remote_state" "mumbai" {
  backend = "s3"
  config = {
    bucket         = "xxxxx123-s3-ga"
    key            = "mumbai/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "xxxxx123-db-ga"
  }
}

data "terraform_remote_state" "ireland" {
  backend = "s3"
  config = {
    bucket         = "xxxxx123-s3-ga"
    key            = "ireland/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "xxxxx123-db-ga"
  }
}


// as GA knew region and ALB ARN, it can create the endpoint group for each region

resource "aws_globalaccelerator_accelerator" "this" {
  name            = "multi-region-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

  tags = {
    Name = "multi-region-accelerator"
  }
}

// listens 

resource "aws_globalaccelerator_listener" "this" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  protocol        = "TCP"
  port_range {
    from_port = 80
    to_port   = 80
  }
}

// endpoint in region being attached with thier ALBs ARN

resource "aws_globalaccelerator_endpoint_group" "mumbai" {
  listener_arn          = aws_globalaccelerator_listener.this.id
  endpoint_group_region = "ap-south-1"

 endpoint_configuration {
    endpoint_id = data.terraform_remote_state.mumbai.outputs.alb_arn
    weight      = 128
  }
}

resource "aws_globalaccelerator_endpoint_group" "ireland" {
  listener_arn          = aws_globalaccelerator_listener.this.id
  endpoint_group_region = "eu-west-1"

  endpoint_configuration {
    endpoint_id = data.terraform_remote_state.ireland.outputs.alb_arn
    weight      = 128
  }
}

// The data "terraform_remote_state" block is exactly how you tell 
// Terraform to read outputs from another module’s 
// state file—whether that state file is local or in S3.
// Instead, you use the data "terraform_remote_state"
// block to point to the remote state (S3 bucket, key, region).

//The data "terraform_remote_state" block points to the S3
 //state file for Mumbai.
//The endpoint_id = data.terraform_remote_state.mumbai.outputs.alb_arn line fetches
 //the ALB ARN from that state file’s outputs.