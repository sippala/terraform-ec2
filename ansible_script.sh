#!/bin/bash
set -x
key_path="/path/to/pem_file"

echo -e "all:"
echo -e "  vars:"
echo -e "    ansible_connections: ssh"
echo -e "    ansible_user: ${user}"
echo -e "    ansible_become: true"
echo -e "    ansible_ssh_private_key_file: \"$key_path\""
echo -e "    jmxexporter_enabled: true"
#echo -e "    ansible_host_key_checking: False"

echo -e "\nzookeeper:"
echo -e "  hosts:"
for i in ${zookeeper_ips}
do
  echo -e "    "$i:
done

echo -e "\nkafka_broker:"
echo -e "  hosts:"
for i in ${broker_ips}
do
  echo -e "    "$i:
done

echo -e "\nschema_registry:"
echo -e "  hosts:"
for i in ${zookeeper_ips}
do
  echo -e "    "$i:
done

echo -e "\ncontrol_center:"
echo -e "  hosts:"
for i in ${cc_ips}
do
  echo -e "    "$i:
done

echo -e "\nkafka_connect:"
echo -e "  hosts:"
for i in ${zookeeper_ips}
do
  echo -e "    "$i:
done

echo -e "\nkafka_rest:"
echo -e "  hosts:"
for i in ${zookeeper_ips}
do
  echo -e "    "$i:
done

echo -e "\nksql:"
echo -e "  hosts:"
for i in ${zookeeper_ips}
do
  echo -e "    "$i:
done
