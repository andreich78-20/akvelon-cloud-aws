resource "aws_security_group" "lab-counter-public-access-sg" {
  description = "Enable HTTP access via port 80 + SSH access"
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = var.vpc_id
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Lab = var.lab_name }
}

resource "aws_instance" "lab-counter-web-server" {
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair_name
  depends_on = [aws_security_group.lab-counter-public-access-sg, aws_db_instance.lab-counter-db]
  vpc_security_group_ids = [aws_security_group.lab-counter-public-access-sg.id]
  iam_instance_profile = aws_iam_instance_profile.app_cloudwatch_role_profile.name
  tags = { Lab = var.lab_name }
  user_data = <<-EOT
    #!/bin/bash

    curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash -
    sudo yum update -y && sudo yum install -y nodejs npm git
    curl https://s3.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-3.x.rpm -o /home/ec2-user/xray.rpm
    sudo yum install -y /home/ec2-user/xray.rpm
    git clone https://github.com/andreich78-20/akvelon-cloud-aws.git counter-web-server
    cd counter-web-server/iac/homework/counter-logs/app
    npm install
    npm install -y mysql
    sudo npm install -g pm2
    echo 'module.exports = {
      apps : [
          {
            name: "counter",
            script: "./index.js",
            watch: false,
            env: {
                "DB_USERNAME": "${var.db_username}",
                "DB_PASSWORD": "${var.db_password}",
                "DB_NAME": "${var.db_name}",
                "DB_ENDPOINT": "${aws_db_instance.lab-counter-db.address}",
                "LOGS_REGION": "${var.region}",
                "LOGS_API_VERSION": "2014-03-28",
                "LOGS_GROUP": "${aws_cloudwatch_log_group.app_lg.name}",
                "LOGS_STREAM": "${aws_cloudwatch_log_stream.app_log_stream.name}"
            }
          }
      ]
    }' > ecosystem.config.js && \
  pm2 startup systemd && sudo pm2 start ecosystem.config.js && sudo pm2 save
  EOT

}
