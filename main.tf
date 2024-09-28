provider "aws" {
  region = "us-east-1"  
}
# Custom Jenkins Server
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  key_name      = "MobaTermKey"  # Use your key pair name 
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "Jenkins"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name jenkins -p 8080:8080 linksrobot/my-jenkins:v2.0",
      
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
      "set -ex",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name sonar -p 9000:9000 sonarqube"
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
      "set -ex",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name nexus -p 8081:8081 sonatype/nexus3"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem")  
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "MobaTermKey"  
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "Monitoring"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      # Install Prometheus
      "sudo docker run -d -p 9090:9090 --name prometheus prom/prometheus",
      # Install Grafana
      "sudo docker run -d -p 3000:3000 --name grafana grafana/grafana"
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
    monitoring  = aws_instance.monitoring.public_ip   
  }
}
