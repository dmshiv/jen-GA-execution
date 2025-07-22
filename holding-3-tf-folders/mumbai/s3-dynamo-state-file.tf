// shall use s3 and dynamo db for files storage 

terraform {
  backend "s3" {
    bucket         = "xxxxx123-s3-ga" // bucket name
    key            = "mumbai/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "xxxxx123-db-ga"
    encrypt        = true
  }
}
