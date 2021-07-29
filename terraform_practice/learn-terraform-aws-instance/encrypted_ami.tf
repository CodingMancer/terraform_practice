/* resource "aws_ami_copy" "ubuntu-xenial-encrypted-ami" {
name of the instance
  name              = "ubuntu-xenial-encrypted-ami"
  #description of the description / application
  description       = "An encrypted root ami based off ${data.aws_ami.ubuntu-xenial.id}"
  source_ami_id     = "${data.aws_ami.ubuntu-xenial.id}"
  #region to be provisioned in
  source_ami_region = "us-east-1"
  #says for itself
  encrypted         = true

  tags {
      Name = "ubuntu-xenial-encrypted-ami"
  }
}

data "aws_ami" "encrypted-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-xenial-encrypted"]
  }

  owners = ["self"]
}

data "aws_ami" "ubuntu-xenial" {
  most_recent = 
  
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}
 */
