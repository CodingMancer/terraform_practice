#looks like provider needs to always be on the top or a "future version" error will appear
provider "aws" {
  region = "us-east-1"
}

module "ec2_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "my-cluster"
  instance_count = 1

  #ensure the ami id is within the region you've specified above or you'll get a "invalidamiid.notfound" error :) 
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  key_name      = "user1"
  monitoring    = true
  #Looking to figure out how to create and assign vpc with igc and sub id
  /*   vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = "subnet-eddcdzz4" */

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#keepforgettingtocheckoutbeforeworkinglol