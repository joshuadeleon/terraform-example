# Variation of https://www.terraform.io/intro/getting-started/

#####################################################
# Example of a local variables
#####################################################
variable "instance_type" {
   default = "t2.micro"
}
variable "ami" {
   type = "map"
   default = {
      "us-west-2" = "ami-48ce0c30"  # ubuntu 17.10 amd64 hvm-ssd 20171017
      "us-east-1" = "ami-b374d5a5"
   }
}

#####################################################
# Configure and provision resources
#####################################################
provider "aws" {
   profile = "personal"    # chooses profile by name in credentials file
   region  = "${var.region}"  # variable defined in a different file
}

resource "aws_instance" "terraform-example" {
   ami            = "${lookup(var.ami, var.region)}"  # alternatively static lookup: ${var.ami["us-west-2"]}
   instance_type  = "${var.instance_type}"

   # Defines local provisioner to execute command locally
   provisioner "local-exec" {
      command = "echo ${aws_instance.terraform-example.public_ip} > ip_address.txt"
   }
}

resource "aws_eip" "ip" {
   instance = "${aws_instance.terraform-example.id}"
   depends_on = ["aws_instance.terraform-example"]   # illustrates optional dependency attribute creates after instance
}

#####################################################
# Other independent resources can be added
#####################################################
# resource "aws_instance" "another-resource" {
#    ami            = "ami-48ce0c30"  # ubuntu 17.10 amd64 hvm-ssd 20171017
#    instance_type  = "t2.micro"
# }

#####################################################
# Configure output
#####################################################
output "ip" {
   value = "${aws_eip.ip.public_ip}"
}

output "instance_type" {
   value = "${aws_instance.terraform-example.instance_type}"
}