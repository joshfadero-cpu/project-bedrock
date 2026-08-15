#!/usr/bin/env bash
#
# Deploys the retail store application to the Bedrock cluster.
#
# Everything the application needs, in order: the namespace, the
# database credentials read from SSM, and the vendored Helm chart.
# Safe to run repeatedly, and this is the whole procedure after a
# rebuild.
#
# Usage: ./scripts/deploy-app.sh

set -euo pipefail

REGION="us-east-1"
CLUSTER="project-bedrock-cluster"
NAMESPACE="retail-app"
RELEASE="retail-store"
CHART="helm/retail-store"

echo "==> Pointing kubectl at $CLUSTER"
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"

echo "==> Creating namespace $NAMESPACE"
kubectl apply -f kubernetes/base/namespace.yaml

echo "==> Creating database secrets from SSM Parameter Store"
./scripts/create-db-secrets.sh

echo "==> Deploying $RELEASE from the vendored chart"
helm upgrade --install "$RELEASE" "$CHART" \
  --namespace "$NAMESPACE" \
  --values "$CHART/values.yaml" \
  --wait --timeout 10m

echo "==> Waiting for the user interface to be ready"
kubectl rollout status "deployment/${RELEASE}-ui" -n "$NAMESPACE" --timeout=300s

echo "==> Waiting for the load balancer address"
for i in $(seq 1 30); do
  ALB=$(kubectl get ingress "${RELEASE}-ui" -n "$NAMESPACE" \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  [ -n "${ALB:-}" ] && break
  sleep 10
done

if [ -z "${ALB:-}" ]; then
  echo "Load balancer address not assigned yet. Check:"
  echo "  kubectl describe ingress ${RELEASE}-ui -n $NAMESPACE"
  exit 1
fi

echo ""
echo "Deployment complete."
echo "Store URL: http://$ALB"
echo ""
echo "Note the http:// prefix. No TLS listener is configured, so a"
echo "browser that upgrades the request to HTTPS will time out."
