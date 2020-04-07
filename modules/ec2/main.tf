resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.ec2_profile_name}"
  role = "${var.role_name}"
}

resource "aws_instance" "ec2" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${var.vpc_security_group_ids}"]
  associate_public_ip_address = "${var.public_ip}"
  source_dest_check           = "${var.source_dest_check}"
  iam_instance_profile        = "${aws_iam_instance_profile.ec2_profile.name}"

  connection {
    host        = "${self.private_ip}"
    user        = "ubuntu"
    private_key = "${file("~/${var.aws-account}-key.pem")}"
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
    Name        = "${var.tag_name}"
  }
}
