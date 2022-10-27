
data "aws_vpc" "selected" {
  default = true
}

data "aws_region" "current" {
  name = "us-east-1"
  
}

####################################################################
################ Security Group for Bastion Host ###################
####################################################################
resource "aws_security_group" "bastion-host-sg" {
  name = var.security-group-name
  description = "Security group for ec2-bastion-host"
  #Used default VPC for testing purpose, provide vpc id to variable vpc-id and use below line.
  #vpc_id = var.vpc-id
  vpc_id = data.aws_vpc.selected.id 
}

resource "aws_security_group_rule" "ec2-ingress-rule" {
    type              = "ingress"
    count = length(var.ingress-rules)
    from_port = var.ingress-rules[count.index][0]
    to_port = var.ingress-rules[count.index][1]
    protocol = var.ingress-rules[count.index][2]
    cidr_blocks = var.ingress-rules[count.index][3]
    description = var.ingress-rules[count.index][4]
    security_group_id = aws_security_group.bastion-host-sg.id
}

resource "aws_security_group_rule" "ec2-egress-rule" {
    type              = "egress"
    count = length(var.egress-rules)
    from_port = var.egress-rules[count.index][0]
    to_port = var.egress-rules[count.index][1]
    protocol = var.egress-rules[count.index][2]
    cidr_blocks = var.egress-rules[count.index][3]
    description = var.egress-rules[count.index][4]
    security_group_id = aws_security_group.bastion-host-sg.id
}

######################################################################
###### IAM Role, Policy and instance profile for Bastion Host ########
######################################################################

resource "aws_iam_policy" "ec2-policy" {
  name        = "ec2-policy"
  path        = "/"
  description = "IAM policy for EC2 bastion host"
  policy = file("${path.module}/ec2-policy.json")
}

resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"
  path = "/"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                "Service": "ec2.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "ec2-role-policy-attachment" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.ec2-policy.arn
}

resource "aws_iam_instance_profile" "ec2-bastion-host-profile" {
  name = var.instance-profile
  role = aws_iam_role.ec2-role.name
}

######################################################################
################# SSH Key managed by Terraform  ####################
####################################################################

resource "tls_private_key" "ec2-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2-ssh-key-pair" {
  key_name = var.key-pair-name
  #provide your public ssh key below 
  #public_key = file("C:\\Users\\ravish.sharma\\.ssh\\id_rsa.pub")
  public_key = tls_private_key.ec2-ssh.public_key_openssh

}

## The below resource block will save the ssh private key with correct file permissions in current working directory as ec2privatekey.pem
## Connect to ec2 instance using this private key
## ssh -i ec2privatekey.pem ec2-user@ec2-xx-xxx-xx-xxx.compute-1.amazonaws.com

resource "local_sensitive_file" "private-ssh-key" {
    content  = tls_private_key.ec2-ssh.private_key_pem
    filename = "${path.module}/ec2privatekey.pem"
    file_permission = "600"
}

######################################################################
####################   EC2 User Data from S3    ######################
####################################################################

resource "aws_s3_bucket" "s3bucket" {
  bucket = "bucket-for-my-ec2-user-dataa"
}

resource "aws_s3_object" "userdata" {
  bucket = aws_s3_bucket.s3bucket.id
  content_type = "text/x-sh"
  key    = "ec2-user-data"
  source = "userdata.sh"
}

data "aws_s3_object" "bootstrap_script" {
  depends_on = [
    aws_s3_object.userdata
  ]
  bucket = aws_s3_bucket.s3bucket.id
  key    = "ec2-user-data"
}


######################################################################
####################   EC2 Bastion Host    #########################
####################################################################

resource "aws_eip" "ec2-eip" {
  vpc = true
  #instance = aws_instance.bastion-host.id
}

resource "aws_instance" "bastion-host" {
  depends_on = [
    data.aws_s3_object.bootstrap_script
  ]
  instance_type = var.ec2-instance-type
  ami           = var.ec2-ami
  vpc_security_group_ids = [aws_security_group.bastion-host-sg.id]
  #Use below line to launch this instance in a specific subnet
  #subnet_id = var.ec2-subnet-id
  iam_instance_profile = aws_iam_instance_profile.ec2-bastion-host-profile.name
  key_name = aws_key_pair.ec2-ssh-key-pair.key_name
  user_data = data.aws_s3_object.bootstrap_script.body
  tags = {
    Name = var.instance-name
  }

  provisioner "local-exec" {
    #interpreter = ["/bin/bash.exe", "-c"]

    command = <<-EOF
    EOF
  }
}

resource "aws_eip_association" "ec2-eip-association" {
  instance_id = aws_instance.bastion-host.id
  allocation_id = aws_eip.ec2-eip.id
}

####### OUTPUTS #######

# This will save the ssh private key in state file
# output "private_key" {    
#   value     = tls_private_key.example.private_key_pem
#   sensitive = true
# }

output "EC2-instance-id" {
  value = aws_instance.bastion-host.id
}

output "EC2-instance-state" {
  value = aws_instance.bastion-host.instance_state
}

output "output" {
  value = data.aws_s3_object.bootstrap_script.body
  
}
