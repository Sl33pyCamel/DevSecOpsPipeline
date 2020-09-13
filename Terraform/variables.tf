variable "regionlocal" {
    type = string
    default = "us-east-1"
    }
    
variable "ingressrules" {
    type = list(number)
    default = [80,443,22,53,8080]
}

variable "egressrules" {
    type = list(number)
    default = [80,443,22,53,8080]
    }
    
variable "private_subnet_1_cidr" {
    type = string
    default = "10.0.10.0/24"
}

variable "public_subnet_1_cidr" {
    type = string
    default = "10.0.1.0/24"
}
  
variable "vpc_cidr" {
   type = string
    default = "10.0.0.0/16"
}
