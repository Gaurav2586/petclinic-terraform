resource "aws_instance" "public" {
  ami = var.AMIS[var.AWS_REGION]
  instance_type = "t2.xlarge"

  # allow Terrform to connect via ssh
  connection {
    host = "${aws_instance.public.public_ip}"
    user = "ubuntu"
    type = "ssh"
    private_key = "${file(var.pvt_sshkey)}"
    timeout = "2m"
  }

  // copy the files to newly created instance
  provisioner "file" {
    source = "files/jenkins-proxy"
    destination = "/tmp/jenkins-proxy"
  }

  provisioner "file" {
    source = "files/Dockerfile"
    destination = "/tmp/Dockerfile"
  }

  provisioner "file" {
    source = "files/jenkins-plugins"
    destination = "/tmp/jenkins-plugins"
  }

  provisioner "file" {
    source = "files/default-user.groovy"
    destination = "/tmp/default-user.groovy"
  }


  provisioner "file" {
    source = "files/credentials.groovy"
    destination = "/tmp/credentials.groovy"
  }
  # run all necessary commands via remote shell
  provisioner "remote-exec" {
    inline = [

      # steps to setup docker ce
      "sudo apt update",
      "sudo apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" ",
      "sudo apt update",
      "sudo apt-cache policy docker-ce",
      "sudo apt -y install docker-ce",

      # build jenkins image with default admin user
      "cd /tmp ",
      "sudo docker build -t gaurav/jenkins . ",

      # run newly built jenkins container on port 8080
      "sudo docker run -d --name jenkins-server -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock gaurav/jenkins",

      # install remaining dependencies
      "sudo apt -y install nginx",
      "sudo apt -y install ufw",

      # setup debian firewall
      "sudo ufw status verbose",
      "sudo ufw default deny incoming",
      "sudo ufw default allow outgoing",
      "sudo ufw allow ssh",
      "sudo ufw allow 22",
      "sudo ufw allow 80",
      "sudo yes | ufw enable",

      # update nginx configuration
      "sudo rm -f /etc/nginx/sites-enabled/default",
      "sudo cp -f /tmp/jenkins-proxy /etc/nginx/sites-enabled",
      "sudo service nginx restart",

      # install ansible
      "sudo apt install ansible -y "
    ]
  }


  # the VPC subnet
  subnet_id = aws_subnet.main-public-1.id

  # the security group
  vpc_security_group_ids = [
    aws_security_group.allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.mykey.key_name

  tags = {
    Name = "CI-Server"
  }
}

resource "aws_instance" "private" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"


  # the VPC subnet
  subnet_id = aws_subnet.main-private-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.mykey.key_name

  tags = {
    Name = "CD-Server"
  }
}
output "public-instance" {
  value = "${aws_instance.public.public_ip}"
}
output "private-instance" {
  value = "${aws_instance.private.private_ip}"
}
output "public-instance-availability-zone" {
  value = "${aws_instance.public.availability_zone}"
}
output "private-instance-availability-zone" {
  value = "${aws_instance.private.availability_zone}"
}
