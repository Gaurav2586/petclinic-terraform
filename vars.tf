variable "AWS_REGION" {
  default = "ap-south-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}

variable "pvt_sshkey" {
  description = "Location of the local private ssh key"
  default = "mykey"
}


variable "AMIS" {
  type = map(string)
  default = {
    ap-south-1 = "ami-0123b531fc646552f"
    us-west-1 = "ami-0dd655843c87b6930"
    eu-west-1 = "ami-844e0bf7"
  }
}
