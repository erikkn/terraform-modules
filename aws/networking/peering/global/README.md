# Terraform module for AWS VPC Peering: Global Peering

This directory contains the Terraform module to create `global` peering connections. `Global` peering connections are peering connections between two VPCs that are both living in different accound **OR** different regions. Make sure that if your VPCs are only in a different region, but in the same account, to change the `region` field in your provider struct.

## Providers

| Name | Version |
|------|---------|
| aws.accepter | n/a |
| aws.requester | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| subnet\_names | Specify the name of the subnets of which you want to update their routing tables. | <pre>object({<br>    requester_subnets = list(string)<br>    accepter_subnets  = list(string)<br>  })<br></pre> | n/a | yes |
| vpc\_names | n/a | <pre>object({<br>    requester_vpc = string<br>    accepter_vpc  = string<br>  })<br></pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_vpc\_peering\_connection\_id | n/a |

## Usage
An example of how to use this module is shown below:

```hcl
 module "foobar" {
   source = "foobar"

   providers = {
     aws.requester = aws.requester
     aws.accepter  = aws.accepter
   }

   vpc_names = {
     requester_vpc = "foobar1"
     accepter_vpc  = "foobar2"
   }

   subnet_names = {
     requester_subnets = ["foobar1-a", "foobar1-b", "foobar1-c"]
     accepter_subnets  = ["foobar2-a"]
   }
 }
```
