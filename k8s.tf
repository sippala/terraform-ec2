resource  "kubernetes_endpoints" "kafka-metrics-ep" {
  metadata {
    labels = {
      app       = "kafka"
      component = "kafka"
      purpose   = "k8s"
    }
    name        = "kafka"
    namespace   = "monitoring"
  }

  subset {
    dynamic "address" {
      iterator = ipaddr
      for_each = concat(aws_instance.ec2_zk.*.private_ip, aws_instance.ec2_broker.*.private_ip)
      content {
        ip = ipaddr.value
      }
    }

    dynamic "port" {
      iterator = port
      for_each = var.kafka_port
      content {
        name     = port.key
        port     = port.value
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_service" "kafka-service" {
  metadata {
    labels    = "${kubernetes_endpoints.kafka-metrics-ep.metadata.0.labels}"
    name      = "${kubernetes_endpoints.kafka-metrics-ep.metadata.0.name}"
    namespace = "${kubernetes_endpoints.kafka-metrics-ep.metadata.0.namespace}"
  }

  spec {
    dynamic "port" {
      iterator = port
      for_each = var.kafka_port
      content {
        name        = port.key
        port        = port.value
        protocol    = "TCP"
        target_port = port.value
      }
    }
  }
}

resource  "kubernetes_endpoints" "jmx-metrics-ep" {
  metadata {
    labels = {
      app       = "jmx-exporter"
      component = "jmx-exporter"
      purpose   = "k8s"
    }
    name        = "jmx-exporter"
    namespace   = "monitoring"
  }

  subset {
    dynamic "address" {
      iterator = ipaddr
      for_each = aws_instance.ec2_broker.*.private_ip
      content {
        ip = ipaddr.value
      }
    }

    dynamic "port" {
      iterator = port
      for_each = var.jmx_port
      content {
        name     = port.key
        port     = port.value
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_service" "jmx-service" {
  metadata {
    labels    = "${kubernetes_endpoints.jmx-metrics-ep.metadata.0.labels}"
    name      = "${kubernetes_endpoints.jmx-metrics-ep.metadata.0.name}"
    namespace = "${kubernetes_endpoints.jmx-metrics-ep.metadata.0.namespace}"
  }

  spec {
    dynamic "port" {
      iterator = port
      for_each = var.jmx_port
      content {
        name        = port.key
        port        = port.value
        protocol    = "TCP"
        target_port = port.value
      }
    }
  }
}
