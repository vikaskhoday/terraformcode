# main.tf

# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "main-vpc"
  }
}

# Create an IAM User
resource "aws_iam_user" "tf_user" {
  name = var.iam_user_name
}

# Create an Access Key for the IAM User
resource "aws_iam_access_key" "tf_user_key" {
  user = aws_iam_user.tf_user.name
}

# Output the Access Key ID and Secret Access Key
output "access_key_id" {
  value     = aws_iam_access_key.tf_user_key.id
  sensitive = true # Mark as sensitive to prevent plain-text output in logs
}

output "secret_access_key" {
  value     = aws_iam_access_key.tf_user_key.secret
  sensitive = true # Mark as sensitive to prevent plain-text output in logs
}

output "vpc_id" {
  value = aws_vpc.main.id
}


# Data source to retrieve the existing VPC
data "aws_vpc" "main-vpc" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"] # Replace with the name tag of your existing VPC
  }
  # Alternatively, you can use the VPC ID directly if known:
  # id = "vpc-xxxxxxxxxxxxxxxxx"
}

# Create a public subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = data.aws_vpc.existing_vpc.id
  cidr_block              = "10.0.1.0/24" # Replace with your desired CIDR block
  availability_zone       = "us-west-1a" # Replace with your desired AZ
  map_public_ip_on_launch = true # Set to true for public subnets

  tags = {
    Name = "public-subnet-1"
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "10.0.2.0/24" # Replace with your desired CIDR block
  availability_zone = "us-west-1b" # Replace with your desired AZ
  # map_public_ip_on_launch is false by default for private subnets

  tags = {
    Name = "private-subnet-1"
  }
}

# Output the IDs of the created subnets
output "public_subnet_id" {
  value = aws_subnet.public_subnet_1.id
}
