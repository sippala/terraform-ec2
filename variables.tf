variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-2"
}

variable "instance_prefix" {
  default     = "cn-dev"
}

variable "aws_ami" {
  description = "The AWS AMI."
  default     = "ami-0d1cd67c26f5fca19"
}

variable "instance_type" {
  description = "The AWS Instance Type."
  default     = "t2.medium"
}

variable "vpc_id"     { default = "" }

variable "subnet_id" {
  default = ""
}

variable "key_name" {
  description = "Key Pair"
  default     = "dev-cn-kafka"
}

variable "user"             { default = "ubuntu" }
variable "script_file"      { default = "bootstrap.sh" }
variable "ansible_file"     { default = "ansible_script.sh" }
variable "hosts_file"       { default = "hosts_file.sh" }
variable "dir_path"         { default = "~/kafka-cluster/cp-ansible" }

variable "public_ip_allow"  { default = "false" }
variable "role_name"        { default = "kafka-ec2-iam-role" }
variable "test_bucket"      { default = "dd-shankar-test" }

variable "source_dest_check" { default = "" }
variable "bk_count"  { default = "2" }
variable "cc_count"  { default = "1" }
variable "zk_count"  { default = "3" }

variable "bk_profile_name" { default = "bk-kafka" }
variable "cc_profile_name" { default = "cc-kafka" }
variable "zk_profile_name" { default = "zk-kafka" }

variable "k8s_file"        { default = "k8s_script.sh" }
variable "k8s_rendered"    { default = "k8s_rendered.sh" }
variable "k8s_yaml"        { default = "kafka_k8s.yaml" }
