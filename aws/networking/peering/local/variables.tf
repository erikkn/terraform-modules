variable "vpc_names" {
  type = object({
    requester_vpc = string
    accepter_vpc  = string
  })
}

variable "subnet_names" {
  description = "Specify the name of the subnets of which you want to update their routing tables."
  type = object({
    requester_subnets = list(string)
    accepter_subnets  = list(string)
  })
}

