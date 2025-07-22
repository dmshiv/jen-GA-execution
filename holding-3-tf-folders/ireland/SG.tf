// 8 creating security group with port 22 ,80 ec2 a well as ALB

resource "aws_security_group" "create_security_group" {
  name        = "ireland-sg"
  description = "Security group for mumbai"
  vpc_id      = aws_vpc.create_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from anywhere
  }

  tags = {
    Name = "Sg-for-ireland" # Tag for the security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }


}


