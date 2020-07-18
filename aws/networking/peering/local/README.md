# Terraform module for AWS VPC Peering: Local Peering

This module contains the Terraform module to create a `local` peering connection between two VPCs. The `local` type is a connection between two VPCs in the same account **AND** the same region.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| subnet\_names | Specify the name of the subnets of which you want to update their routing tables. | <pre>object({<br>    requester_subnets = list(string)<br>    accepter_subnets  = list(string)<br>  })<br></pre> | n/a | yes |
| vpc\_names | n/a | <pre>object({<br>    requester_vpc = string<br>    accepter_vpc  = string<br>  })<br></pre> | n/a | yes |

## Usage
An example of how to use this module is shown below:

```hcl
 module "foobar" {
   source = "foobar"

   vpc_names = {
     requester_vpc = "foobar"
     accepter_vpc  = "foobar"
   }

   subnet_names = {
     requester_subnets = ["foobar1", "foobar2"]
     accepter_subnets  = ["foobar1", "foobar3"]
   }
 }
```
