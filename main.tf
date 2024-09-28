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
      "set -e",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      # Install OWASP Dependency-Check
      "sudo apt-get install -y openjdk-11-jre-headless",
      "wget https://github.com/jeremylong/DependencyCheck/releases/download/v7.2.1/dependency-check-7.2.1-release.zip",
      "unzip dependency-check-7.2.1-release.zip -d /opt/dependency-check",
      "ln -s /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check",
      # Install Custom Jenkins
      "sudo docker run -d -p 8080:8080 linksrobot/my-jenkins:v2.0",
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
      "set -e",
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

resource "aws_instance" "owasp_zap" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "MobaTermKey"  
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "OWASP ZAP"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      # Install OWASP ZAP
      "sudo apt-get install -y openjdk-11-jre-headless",
      "sudo docker run -u zap -p 8080:8080 -i owasp/zap2docker-stable zap.sh -daemon -host 0.0.0.0 -port 8080"
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
    monitoring  = aws_instance.monitoring.public_ip
    owasp_zap = aws_instance.owasp_zap.public_ip
  }
}
