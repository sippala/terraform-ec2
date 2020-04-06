#!/bin/bash
echo -e "---
apiVersion: v1
kind: Service
metadata:
  name: kafka
  labels:
    app: kafka
    component: kafka
    purpose: k8s
spec:
  ports:
  - name: node-metrics
    port: 9100
    protocol: TCP
    targetPort: 9100
  - name: kafka-metrics
    port: 9308
    targetPort: 9308
    protocol: TCP
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: v1
kind: Endpoints
metadata:
  labels:
    app: kafka
    component: kafka
    purpose: k8s
  name: kafka
subsets:
  - addresses:"
for i in ${all_ips}
do
  echo -e "      - ip: "$i
done
echo -e "    ports:
      - name: node-metrics
        port: 9100
        protocol: TCP
      - name: kafka-metrics
        port: 9308
        protocol: TCP
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: kafka
  labels:
    k8s-app: kafka"
echo -e '    scrape: "true"'
echo -e "spec:
  endpoints:
  - interval: 10s
    path: /metrics
    port: node-metrics
  - interval : 10s
    path: /metrics
    port: kafka-metrics
  namespaceSelector:
    matchNames:
    - monitoring
  selector:
    matchLabels:
      component: kafka
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: jmx-exporter
    jobLabel: jmx-exporter"
echo -e '    scrape: "true"'
echo -e "  name: jmx-exporter
spec:
  clusterIP: None
  ports:
  - name: jmx-metrics
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: jmx-exporter
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: v1
kind: Endpoints
metadata:
  name: jmx-exporter
subsets:
  - addresses:"
for i in ${broker_ips}
do
  echo -e "      - ip: "$i
done
echo -e "    ports:
      - name: jmx-metrics
        port: 8080
        protocol: TCP
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: jmx-exporter"
echo -e '    scrape: "true"'
echo -e "  name: jmx-exporter
  namespace: monitoring
spec:
  endpoints:
  - interval: 15s
    path: /metrics
    port: jmx-metrics
  namespaceSelector:
    matchNames:
    - monitoring
  selector:
    matchLabels:
      app: jmx-exporter"
