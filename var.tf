######################################################################
####################   EC2 Bastion Host    #########################
####################################################################

variable "access_key" {
default = ""
}

variable "secret_key" {
default = ""
}

variable "security-group-name" {
  default = "allow-ssh"
  type = string
  description = "Name of the security group for EC2 bastion host"
}

variable "vpc-id" {
  default = "vpc-7508eb11"
  type = string
  description = "VPC ID for EC2 Bastion host and security group"
}

variable "ec2-subnet-id" {
  default = "subnet-eda3959a"
  type = string
  description = "Subnet ID to launch EC2 Bastion host"
}

variable "ingress-rules" {
    description = "list of lists of parameters to create multiple ingress rule in format [[from_port,to_port,protocol,cidr_blocks,description],[from_port,to_port,protocol,cidr_blocks,description]....] "
    default = [
                [22,22,"tcp",["0.0.0.0/0"],"allow ssh"],
                [80,80,"tcp",["0.0.0.0/0"],"allow http"],
                [443,443,"tcp",["0.0.0.0/0"],"allow https"],
                [3389,3389,"tcp",["0.0.0.0/0"],"allow rdp"]
            ]

}

variable "egress-rules" {
    description = "list of lists of parameters to create multiple egress rule in format [[from_port,to_port,protocol,cidr_blocks],[from_port,to_port,protocol,cidr_blocks]....] "
    default = [
        [0,0,"-1",["0.0.0.0/0"],"allow all traffic"]
        ]
}

variable "key-pair-name" {
  default = "ssh-key"
  type = string
  description = "Name of the Key Pair for EC2 Bastion host"
}

variable "ec2-ami" {
  default = "ami-05fa00d4c63e32376"
  type = string
  description = "AMI to use for launching EC2 Bastion host"
}

variable "ec2-instance-type" {
  default = "t2.micro"
  type = string
  description = "Instance type for launching EC2 Bastion host"
}

variable "instance-name" {
  default = "bastion-host"
  type = string
  description = "Name of EC2 Bastion host"
}

variable "instance-profile" {
  default = "ec2-bastion-host-profile"
  type = string
  description = "Name of the instance profile to be created"
}

################################################################
################    RDS Security Group     #####################
################################################################
variable rds-security-group-name{
    default = "rds-sg"
    type = string
    description = "Name of the Security group for RDS"
}

variable "rds-vpc-id" {
  default = "vpc-7508eb11"
  type = string
  description = "VPC ID to launch RDS"
}

variable "ingress-rules-rds" {
    description = "list of lists of parameters to create multiple ingress rule in format [[from_port,to_port,protocol,cidr_blocks],[from_port,to_port,protocol,cidr_blocks]....] "
    default = [
                [22,22,"tcp",["0.0.0.0/0"],"allow ssh"],
                [80,80,"tcp",["0.0.0.0/0"],"allow http"],
                [443,443,"tcp",["0.0.0.0/0"],"allow https"],
                [3389,3389,"tcp",["0.0.0.0/0"],"allow rdp"]
            ]
}

variable "egress-rules-rds" {
    description = "list of lists of parameters to create multiple egress rule in format [[from_port,to_port,protocol,cidr_blocks],[from_port,to_port,protocol,cidr_blocks]....] "
    default = [
        [0,0,"-1",["0.0.0.0/0"],"allow all traffic"]
        ]
}
