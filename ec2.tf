data "template_file" "script_file" {
  template = "${file("${var.script_file}")}"
}

module "iam" {
  source          = "./modules/iam"
  role_name       = "${var.role_name}"
  test_bucket     = "${var.test_bucket}"
}

data "template_file" "ansible_file" {
  template = "${file("${var.ansible_file}")}"
  vars {
    zookeeper_ips = "${join(" ", aws_instance.ec2_zk.*.private_ip)}"
    broker_ips    = "${join(" ", aws_instance.ec2_broker.*.private_ip)}"
    cc_ips        = "${join(" ", aws_instance.ec2_cc.*.private_ip)}"
    user          = "${var.user}"
  }
}

data "template_file" "k8s_file" {
  template = "${file("${var.k8s_file}")}"
  vars {
    all_ips       = "${join(" ", aws_instance.ec2_zk.*.private_ip, aws_instance.ec2_broker.*.private_ip)}"
    zookeeper_ips = "${join(" ", aws_instance.ec2_zk.*.private_ip)}"
    broker_ips    = "${join(" ", aws_instance.ec2_broker.*.private_ip)}"
    cc_ips        = "${join(" ", aws_instance.ec2_cc.*.private_ip)}"
  }
}

######################################################################################
resource "aws_iam_instance_profile" "bk_profile" {
  name  = "${var.bk_profile_name}"
  role  = "${module.iam.name}"
}

resource "aws_instance" "ec2_broker" {
  count                       = "${var.bk_count}"
  ami                         = "${var.aws_ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${aws_security_group.kafka_sg.id}"]
  associate_public_ip_address = "${var.public_ip_allow}"
  source_dest_check           = "${var.source_dest_check}"
  #iam_instance_profile       = "${element(aws_iam_instance_profile.bk_profile.*.name, count.index)}"
  iam_instance_profile        = "${aws_iam_instance_profile.bk_profile.name}"

  connection {
    host        = "${self.private_ip}"
    user        = "ubuntu"
    private_key = "${file("~/${var.aws-account}-cn-kafka.pem")}"
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "bash /tmp/bootstrap.sh"
    ]
  }

  tags {
    Name        = "kafka-broker-${var.instance_prefix}-${count.index + 1}"
  }
}

output "broker_ips" {
  value = ["${aws_instance.ec2_broker.*.private_ip}"]
}

######################################################################################
resource "aws_instance" "ec2_cc" {
  count                       = "${var.cc_count}"
  ami                         = "${var.aws_ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${aws_security_group.kafka_sg.id}"]
  associate_public_ip_address = "${var.public_ip_allow}"
  source_dest_check           = "${var.source_dest_check}"
  #iam_instance_profile       = "${element(aws_iam_instance_profile.cc_profile.*.name, count.index)}"
  iam_instance_profile        = "${aws_iam_instance_profile.bk_profile.name}"

  connection {
    host        = "${self.private_ip}"
    user        = "ubuntu"
    private_key = "${file("~/${var.aws-account}-cn-kafka.pem")}"
  }

  provisioner "file" {
    source      = "bootstrap_zk.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "bash /tmp/bootstrap.sh"
    ]
  }

  tags {
    Name        = "kafka-cc-${var.instance_prefix}-${count.index + 1}"
  }
}

output "cc_ips" {
  value = ["${aws_instance.ec2_cc.*.private_ip}"]
}

###################################################################################
resource "aws_instance" "ec2_zk" {
  count                       = "${var.zk_count}"
  ami                         = "${var.aws_ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${aws_security_group.kafka_sg.id}"]
  associate_public_ip_address = "${var.public_ip_allow}"
  source_dest_check           = "${var.source_dest_check}"
  #iam_instance_profile       = "${element(aws_iam_instance_profile.zk_profile.*.name, count.index)}"
  iam_instance_profile        = "${aws_iam_instance_profile.bk_profile.name}"

  connection {
    host        = "${self.private_ip}"
    user        = "ubuntu"
    private_key = "${file("~/${var.aws-account}-cn-kafka.pem")}"
  }

  provisioner "file" {
    source      = "bootstrap_zk.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "bash /tmp/bootstrap.sh"
    ]
  }

  tags {
    Name        = "kafka-zookeeper-${var.instance_prefix}-${count.index + 1}"
  }
}

output "zookeeper_ips" {
  value = ["${aws_instance.ec2_zk.*.private_ip}"]
}

###########################################################################
resource "local_file" "foo" {
  content  = "${data.template_file.ansible_file.rendered}"
  filename = "${var.hosts_file}"
}

resource "local_file" "k8s" {
  content  = "${data.template_file.k8s_file.rendered}"
  filename = "${var.k8s_rendered}"
}

resource "null_resource" "script" {
  triggers {
    build_number       = "${timestamp()}"
  }
  provisioner "local-exec" {
    command =<<EOT
      rm ${var.dir_path}/hosts.yml
      bash ${var.hosts_file} >> ${var.dir_path}/hosts.yml
      #ansible -i ${var.dir_path}/hosts.yml all -m ping
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.dir_path}/hosts.yml ${var.dir_path}/all.yml
    EOT
    command =<<EOT
      rm ${var.k8s_yaml}
      bash ${var.k8s_rendered} >> ${var.k8s_yaml}
      kubectl apply -f ${var.k8s_yaml} -n monitoring
    EOT
  }
  depends_on  = ["aws_instance.ec2_zk", "aws_instance.ec2_broker", "aws_instance.ec2_cc", "local_file.foo", "local_file.k8s"]
}
