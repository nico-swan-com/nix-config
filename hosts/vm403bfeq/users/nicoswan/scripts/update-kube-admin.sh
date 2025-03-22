#!/bin/bash

#rm ~/.kube/ca.pem ~/.kube/cluster-admin.pem ~/.kube/cluster-admin-key.pem
#sudo cp /var/lib/kubernetes/secrets/ca.pem ~/.kube/
#sudo cp /var/lib/kubernetes/secrets/cluster-admin.pem ~/.kube/
#sudo cp /var/lib/kubernetes/secrets/cluster-admin-key.pem ~/.kube/
#sudo chown $USER ~/.kube/cluster-admin.pem
#sudo chown $USER ~/.kube/cluster-admin-key.pem
#sudo chown $USER ~/.kube/ca.pem

# Base64-encoded certificate data
CA_CERT=$(sudo cat /var/lib/kubernetes/secrets/ca.pem | base64 -w 0)
CLIENT_CERT=$(sudo cat /var/lib/kubernetes/secrets/cluster-admin.pem | base64 -w 0)
CLIENT_KEY=$(sudo cat /var/lib/kubernetes/secrets/cluster-admin-key.pem | base64 -w 0)
HOST="$(hostname -f)"

# Generate kubeconfig content
cat <<EOF >~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $CA_CERT
    server: https://$HOST:6443
  name: $HOST
contexts:
- context:
    cluster: $HOST
    user: cluster-admin
  name: $HOST
current-context: $HOST
kind: Config
preferences: {}
users:
- name: cluster-admin
  user:
    client-certificate-data: $CLIENT_CERT
    client-key-data: $CLIENT_KEY
EOF

echo "Kubeconfig file generated successfully!"
