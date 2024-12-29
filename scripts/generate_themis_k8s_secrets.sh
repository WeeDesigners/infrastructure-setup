#!/bin/bash
# !IMPORTANT this script is advised to be run by a makefile, it is not idiot-proof.
# !Make sure you understand what it is doing before running it

if [ $# -ne 4 ]; then
    echo "Invalid argument number, usage: 
    generate_themis_secrets [cluster name] [cluster user] [kubernetes secret name] [kubernetes namespace]"
    exit 1
fi

CLUSTER_NAME=$1
CLUSTER_USER=$2
KUBERNETES_SECRET_NAME=$3
THEMIS_NAMESPACE=$4

KUBERNETES_MASTER=$(kubectl config view --flatten \
                    | yq -r ".clusters[] | select(.name == \"$CLUSTER_NAME\") | .cluster.server ")
if [ -z "$KUBERNETES_MASTER" ]; then
    echo "[General failure] Failed to get kubernetes master address. Please ensure that kubeconfig is set properly"
    exit 1
fi

KUBERNETES_CA_CERT_DATA=$(kubectl config view --flatten \
                          | yq -r ".clusters[] | select(.name == \"$CLUSTER_NAME\") | .cluster.\"certificate-authority-data\"")

if [ -z "$KUBERNETES_CA_CERT_DATA" ]; then
    echo "[General failure] Failed to get kubernetes CA data. Please ensure that kubeconfig is set properly"
    exit 1
fi

KUBERNETES_CLIENT_CERT_DATA=$(kubectl config view --flatten \
                          | yq -r ".users[] | select(.name == \"$CLUSTER_USER\") | .user.\"client-certificate-data\"")
KUBERNETES_CLIENT_KEY_DATA=$(kubectl config view --flatten \
                          | yq -r ".users[] | select(.name == \"$CLUSTER_USER\") | .user.\"client-key-data\"")
if [ -z "$KUBERNETES_CLIENT_CERT_DATA" ] || [ -z "$KUBERNETES_CLIENT_KEY_DATA" ]; then
    echo "[General failure] Failed to get kubernetes user data. Please ensure that kubeconfig is set properly"
    exit 1
fi
kubectl get namespace $THEMIS_NAMESPACE
if [ $? -eq 1 ]; then
    echo "Namespace $THEMIS_NAMESPACE not found. Creating..."
    kubectl create namespace $THEMIS_NAMESPACE || exit 1
fi

kubectl create secret generic --namespace=themis-executor $KUBERNETES_SECRET_NAME \
    --from-literal=KUBERNETES_MASTER="$KUBERNETES_MASTER" \
	--from-literal=KUBERNETES_CA_CERT_DATA="$KUBERNETES_CA_CERT_DATA" \
	--from-literal=KUBERNETES_CLIENT_CERT_DATA="$KUBERNETES_CLIENT_CERT_DATA" \
	--from-literal=KUBERNETES_CLIENT_KEY_DATA="$KUBERNETES_CLIENT_KEY_DATA" || exit 1