#!/bin/bash
sudo apt-get update
sudo apt update
sudo apt install -y python3
sudo apt-get install go-dep
#sudo apt install -y python3-pip

#installing node_exporter
curl -L -O  https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz
tar -xzvf node_exporter-0.17.0.linux-amd64.tar.gz
mkdir -p /home/ubuntu/prometheus/
mv node_exporter-0.17.0.linux-amd64 /home/ubuntu/prometheus/node_exporter
rm node_exporter-0.17.0.linux-amd64.tar.gz

#installing kafka_exporter
curl -L -O https://github.com/danielqsj/kafka_exporter/releases/download/v1.2.0/kafka_exporter-1.2.0.linux-amd64.tar.gz
tar -xzvf kafka_exporter-1.2.0.linux-amd64.tar.gz
mkdir -p /home/ubuntu/prometheus/
mv kafka_exporter-1.2.0.linux-amd64 /home/ubuntu/prometheus/kafka_exporter
rm kafka_exporter-1.2.0.linux-amd64.tar.gz

# Add node_exporter as systemd service
sudo tee -a /etc/systemd/system/node_exporter.service << END
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=ubuntu
ExecStart=/home/ubuntu/prometheus/node_exporter/node_exporter
[Install]
WantedBy=default.target
END

# Add kafka_exporter as systemd service
sudo tee -a /etc/systemd/system/kafka_exporter.service << END
[Unit]
Description=Kafka Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=ubuntu
ExecStart=/home/ubuntu/prometheus/kafka_exporter/kafka_exporter --kafka.server=localhost:9092
[Install]
WantedBy=default.target
END

sudo systemctl daemon-reload

sudo systemctl start node_exporter
sudo systemctl enable node_exporter

sudo systemctl start kafka_exporter
sudo systemctl enable kafka_exporter
