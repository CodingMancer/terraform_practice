#Start with this first
#This tells Terraform what provider this code will be used for along with the region
provider "aws" {
  region = "us-east-1"
}

# the "resource" variable is to create
#ami requires an AMI ID which is available in AWS
resource "aws_instance" "my-first-server" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"

  tags = {
    "Name" = "linux_server"
  }
}
#As long as the ip is within the /16 and /24, it should be fine
#this is creating the vpc and it's name
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  #vpcname
  tags = {
    Name = "testvpc"
  }
}
#this is the subnet using the vpc id, see above
#it'll then reference the resource above
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  #subnetname
  tags = {
    "Name" = "testsubnet"
  }
}

/* tags = {
    Name = "testinstance"
} */

/* resource "<provider>_<resourcetype>" "name" {
  configuration options
  key =
  key 2 = 
} */
