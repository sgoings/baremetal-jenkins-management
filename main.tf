provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-east-1"
}

resource "aws_security_group" "allow_all" {
  name = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "puppet_master" {
  ami = "${var.aws_ubuntu_ami}"
  instance_type = "t2.small"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  tags {
    Name = "puppet_master"
  }
  provisioner "remote-exec" {
    script = "scripts/puppet_master.sh"
    connection {
      user = "ubuntu"
      key_file = "${var.aws_key_path}"
    }
  }
}

resource "aws_eip" "puppet_master" {
  instance = "${aws_instance.puppet_master.id}"
}

resource "aws_route53_record" "puppet" {
  zone_id = "${var.route53_zone_id}"
  name = "puppet.${var.domain}"
  type = "A"
  ttl = "60"
  records = ["${aws_eip.puppet_master.public_ip}"]
}

#Jenkins Master
resource "aws_instance" "jenkins_master" {
  ami = "${var.aws_ubuntu_ami}"
  instance_type = "t2.small"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  tags {
    Name = "jenkins_master"
  }
  provisioner "remote-exec" {
    scripts = [
      "scripts/puppet-agent.sh",
      "scripts/jenkins_master.sh"
    ]
    connection {
      user = "ubuntu"
      key_file = "${var.aws_key_path}"
    }
  }
}

resource "aws_eip" "jenkins_master" {
  instance = "${aws_instance.jenkins_master.id}"
}

resource "aws_route53_record" "jenkins_master" {
  zone_id = "${var.route53_zone_id}"
  name = "jenkins.${var.domain}"
  type = "A"
  ttl = "60"
  records = ["${aws_eip.jenkins_master.public_ip}"]
}

#Jenkins Slave
resource "aws_instance" "jenkins_slave1" {
  ami = "${var.aws_ubuntu_ami}"
  instance_type = "t2.small"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  tags {
    Name = "jenkins_slave1"
  }
  provisioner "remote-exec" {
    scripts = [
      "scripts/puppet-agent.sh"
    ]
    connection {
      user = "ubuntu"
      key_file = "${var.aws_key_path}"
    }
  }
}

resource "aws_eip" "jenkins_slave1" {
  instance = "${aws_instance.jenkins_slave1.id}"
}

resource "aws_route53_record" "jenkins_slave1" {
  zone_id = "${var.route53_zone_id}"
  name = "slave1.${var.domain}"
  type = "A"
  ttl = "60"
  records = ["${aws_eip.jenkins_slave1.public_ip}"]
}

output "jenkins_master_fqdn" {
  value = "${aws_route53_record.jenkins_master.fqdn}"
}

output "jenkins_slave1_fqdn" {
  value = "${aws_route53_record.jenkins_slave1.fqdn}"
}

output "puppet_master_fqdn" {
  value = "${aws_route53_record.puppet.fqdn}"
}
