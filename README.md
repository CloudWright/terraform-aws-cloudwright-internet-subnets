For VPC networks with an existing Internet Gateway but no NAT gateway configured (expected to be common at companies with VMs but not currently using VPC-connected Lambdas)

This module configures:

- a private subnet to attach CW Lambdas to
- a public subnet attached to the Internet Gateway
- corresponding route tables 
- a NAT Gateway attached to the private subnet
- a minimal egress-capable Security Group to attach to CW Lambdas

### Inputs

- `vpc_id`: the VPC network to attach infrastructure onto
- `region`: provided to the AWS provider
- `availability_zone`: both subnets will be created in this Availability Zone
- `public_cidr_block`: CIDR block to provide to public subnet 
- `private_cidr_block`: CIDR block to provide to private subnet

### Outputs

- `private_subnet_id`: VPC to provide in CW DZ creation dialog
- `lambda_egress_security_group`: Minimal SG to provide during CW DZ creation 

### Example Usage

Invoked standalone from this project:

```python
terraform apply -var 'region=us-east-1' -var 'availability_zone=us-east-1a'  -var 'private_cidr_block=172.0.10.0/24' -var 'public_cidr_block=172.0.11.0/24' -var 'vpc_id=vpc-xxxxxxxx'
```

Invoked as a module in a terraform script:

```hcl
module "cloudwright-internet-subnets" {
  source  = "CloudWright/cloudwright-internet-subnets/aws"
  version = "0.1.0"
  region = "us-east-1"
  availability_zone = "us-east-1a"
  private_cidr_block = "172.0.10.0/24"
  public_cidr_block = "172.0.11.0/24"
  vpc_id = "vpc-xxxxxxxx"
}
```

### Notes

This terraform does not currently try to automatically calculate valid CIDR blocks for the two subnets; a tool like [vpc-free](https://github.com/cavaliercoder/vpc-free) is an easy way to do this by hand, ex

```bash
➜  aws-internet-subnets git:(master) ✗ vpc-free vpc-8d1b68f7
MIN IP      MAX IP         MASK SIZE  BEST            LABEL
172.31.0.0  172.31.15.255  /20  4096                  subnet-832601e4
172.31.16.0 172.31.31.255  /20  4096                  subnet-f720d7ba
172.31.32.0 172.31.47.255  /20  4096                  subnet-bafbdbe6
172.31.48.0 172.31.63.255  /20  4096                  subnet-36d1c839
172.31.64.0 172.31.79.255  /20  4096                  subnet-51ef846f
172.31.80.0 172.31.80.255  /24  256                   subnet-0efaf32b3b70fcebd (Private Subnet)
172.31.81.0 172.31.81.255  /24  256                   subnet-0d61b83b889c1295e (Public Subnet)
172.31.82.0 172.31.255.255      44544 172.31.128.0/17 FREE
```

