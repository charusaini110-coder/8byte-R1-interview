resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids      = [var.ec2_sg_id]
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF
  )

  tags = merge(
    {
      Name        = "8byte-app-${var.environment}"
      Environment = var.environment
    },
    var.tags
  )
}
