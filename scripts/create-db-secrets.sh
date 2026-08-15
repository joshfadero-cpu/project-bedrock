#!/usr/bin/env bash
#
# Reads database passwords from SSM Parameter Store and creates the
# two Kubernetes Secrets the retail store charts expect.
#
# Run after every rebuild: Secrets live only in the cluster, so
# destroying the cluster destroys them.

set -euo pipefail

NAMESPACE="retail-app"
REGION="us-east-1"

echo "Reading credentials from SSM Parameter Store..."

CATALOG_PASSWORD=$(aws ssm get-parameter \
  --name "/project-bedrock/catalog/db-password" \
  --with-decryption --region "$REGION" \
  --query 'Parameter.Value' --output text)

ORDERS_PASSWORD=$(aws ssm get-parameter \
  --name "/project-bedrock/orders/db-password" \
  --with-decryption --region "$REGION" \
  --query 'Parameter.Value' --output text)

echo "Creating Kubernetes secrets in namespace $NAMESPACE..."

kubectl create secret generic catalog-db \
  --namespace "$NAMESPACE" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_USER=catalog \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_PASSWORD="$CATALOG_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic orders-db \
  --namespace "$NAMESPACE" \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_USERNAME=orders \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_PASSWORD="$ORDERS_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Done. Secrets catalog-db and orders-db created."
