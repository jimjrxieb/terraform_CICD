provider "aws" {
  region = "us-east-1"  # Choose the region where you want to deploy
  access_key = "AKIAQMEY6IZSSIYKQZUP"
  secret_key = "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"
}

resource "aws_instance" "server" {
  count         = 5
  ami           = "ami-0e86e20dae9224db8"  # Amazon Linux 2 AMI (find a region-specific AMI ID)
  instance_type = "t2.micro"               # Instance type, change as per your needs

  tags = {
    Name = "MyServer-${count.index + 1}"
  }
}
