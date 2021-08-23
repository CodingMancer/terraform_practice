##1. Create a VPC
resource "aws_vpc" "vpc2" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "vpc2"
  }
}

##2. Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc2.id
}

##3. Create a Custom Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc2.id

  #This is to send to the igw but all traffic is sent here as the default route (0.0.0.0)
  #Insert the IGW we've created above
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  #IPV6 Default route ("::/0")
  #This is an option if you wanted to route via ipv6 so insert the igw again
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "routetable1"
  }
}

##4. Create a Subnet
#assign the vpc that the subnet will be working with
#assign a subnet we're going to use
#set up an AZ
#assign a name to the subnet
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "subnet2"
  }
}

##5. Associate Subnet with RouteTable
#We reference the subnet that we've created within this file
#reference the route table that we've created within this file
resource "aws_route_table_association" "routetable1" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table.id
}

##6. Create Security Group to allow port 22,80,443
#This Security Group will be used to allow web traffic
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.vpc2.id

  #From and To port allows us to specify a range of ports
  #Same number port means ONLY in that port
  #In CIDR_Blocks we can place certain device IP addess to access this
  #Changing it to 0.0.0.0/0 allows anyone to access

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    /* ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block] */
  }

  #HTTP lies in port 80
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    /*  ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block] */
  }

  #SSH lies in port 22
  ingress {
    description = "SSH"
    from_port   = 2
    to_port     = 2
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    /*  ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block] */
  }

  #from and to assigned as "0" allowing all connections
  #Protocol assigned to "-1" means any protocol
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    /*     ipv6_cidr_blocks = ["::/0"] */
  }

  tags = {
    Name = "allow_web"
  }
}

##7. Create a Network Interference with an IP in the subnet that was created in Step 4
#We're going to use the subnet created in this file
#As well as the Security groups
#I won't be using the attachment so it will be left out
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet2.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

  /*   attachment {
    instance = "${fill_in}"
    device_index = 1
  } */
}

##8. Assign an elastic IP to the network interface created in Step 7
#We'll be creating one for both private and public IP (elastic IP)
#EIP relies on the IGW to be deployed first or it'll throw an error
resource "aws_eip" "eip1" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.igw]
}

##9. Create Linux Server and install/enable apache2

resource "aws_instance" "web_server_instance" {
  ami               = "ami-0c2b8ca1dad447f8a"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  #this block of code will be used to install apache onto the server
  #EOF at the top starts the configuration
  #EOF at the bottom stop the configuration
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install2 -y
              sudo systemctl start apache2
              sudo base -c 'echo This guy stinks > /var/www/html/index.html'
              EOF
  tags = {
    Name = "web_server"
  }
}