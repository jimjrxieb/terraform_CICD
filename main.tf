provider "aws" {
  region = "us-east-1"  
}
# Custom Jenkins Server
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "MobaTermKey"  
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "Jenkins"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d -p 8080:8080 linksrobot/my-jenkins:custom"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem") 
      host        = self.public_ip
    }
  }
}

# SonarQube Server
resource "aws_instance" "sonarqube" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "MobaTermKey"  
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "SonarQube"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d -p 9000:9000 sonarqube"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem")  
      host        = self.public_ip
    }
  }
}

# Nexus Server
resource "aws_instance" "nexus" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "MobaTermKey"  
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "Nexus"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d -p 8081:8081 sonatype/nexus3"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem")  
      host        = self.public_ip
    }
  }
}

# Splunk server
resource "aws_instance" "splunk" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "MobaTermKey"  
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "Splunk"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d -p 8000:8000 splunk/splunk"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem")  
      host        = self.public_ip
    }
  }
}

# Grafana Server
resource "aws_instance" "grafana" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "MobaTermKey"  
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "Grafana"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d -p 3000:3000 grafana/grafana"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem")  
      host        = self.public_ip
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

output "instance_ips" {
  value = {
    jenkins  = aws_instance.jenkins.public_ip
    sonarqube = aws_instance.sonarqube.public_ip
    nexus    = aws_instance.nexus.public_ip
    splunk   = aws_instance.splunk.public_ip
    grafana  = aws_instance.grafana.public_ip
  }
}
