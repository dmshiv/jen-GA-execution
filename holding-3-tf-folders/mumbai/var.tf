// 1 var for vpc 

variable "gives_cidr_to_vpc" { // var_for_vpc can give anything 
  description = "CIDR block for the VPC"
  type        = string
  default     = "21.0.0.0/16"

}

// 2 var for subnets
variable "gives_cidr_to_subnets" {
  description = "CIDR block for the subnets"
  type        = list(string)
  default     = ["21.0.1.0/24", "21.0.2.0/24"]
}

// 3 var for availability zones
variable "gives_availability_zones_subnets" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"] # Adjust as needed
}

