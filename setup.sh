#!/usr/bin/env bash
set -euo pipefail

CLUSTER=demo
NAMESPACE=demo
RELEASE=demo
IMAGE=demo-service:1.0.0
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! kind get clusters | grep -qx "$CLUSTER"; then
  kind create cluster --name "$CLUSTER"
fi

kubectl config use-context "kind-$CLUSTER" >/dev/null
kubectl cluster-info --context "kind-$CLUSTER" >/dev/null
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/kind/deploy.yaml
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=180s

docker build -t "$IMAGE" "$ROOT/service"
kind load docker-image "$IMAGE" --name "$CLUSTER"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install "$RELEASE" "$ROOT/chart" \
  --namespace "$NAMESPACE" \
  --set image.repository=demo-service \
  --set image.tag=1.0.0 \
  --wait --timeout 180s
