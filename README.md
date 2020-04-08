# terraform-ec2
Tf code to create EC2 Instances and create ansible config files for confluent-kafka installation

Download confluent-kafka ansible playbook using instructions from 
https://docs.confluent.io/current/installation/cp-ansible/ansible-download.html

In my case, I've downloaded ansible playbook repo to ~/kafka-cluster/cp-ansible/ and so I've defined it in variables.tf

After running terraform apply, it will create a hosts.yml file with the ips of instances that are created using terraform 
and then ansible playbook apply commands are run to do the installation of zookeeper, broker, control center etc packages of confluent-kafka. We use confluent ```jmx_exporter = enabled``` command to enable jmx metrics on all nodes.

This will also create k8s endpoints and services that are required to monitor kafka_exporter, node_exporter and jmx_exporter metrics using terraform kubernetes provider, we also need servicemonitors for all these metrics to be monitored on prometheus that's running on k8s. But serivcemonitor isn't part of terraform kubernetes provider, we have to use third party prometheus provider or use kubectl apply on a yaml file (kafka_k8s.yaml) to create service monitor. I used yaml file here.

As a part of bootstrap action while creating the ec2 instances, each instance will be installed with node-exporter, kafka-exporter which are run as service to continously give metrics in prometheus format. Prometheus installed on k8s will scrape metrics from these instances using ports defined in k8s endpoints.
