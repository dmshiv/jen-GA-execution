// creating 2 subnets in vpc

resource "aws_subnet" "create_subnet" {
  count = length(var.gives_cidr_to_subnets)

  vpc_id            = aws_vpc.create_vpc.id
  cidr_block        = var.gives_cidr_to_subnets[count.index]
  availability_zone = var.gives_availability_zones_subnets[count.index]

  tags = {
    Name = count.index == 0 ? "mumbai-sub-pub" : "mumbai-sub-priv"
    Type = count.index == 0 ? "Public" : "Private"
  }

  # provider = aws.eu-central-1  # Uncomment if you have a specific provider configuration

}
