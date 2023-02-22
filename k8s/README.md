## Get Aks credentials

```bash
az aks get-credentials -g rgaztfpro02 -n aksaztfpro02
```

## Install nginx ingress controller

```bash
kubectl create namespace basic
```

```bash
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace basic --values ./values/nginx_ingress_values.yaml
```

## Install Cert-manager and apply cluster issuer

Modify the email field in the <b>cluster_issuer.yaml</b> file.

```bash
helm install cert-manager jetstack/cert-manager --namespace basic --version v1.11.0 --values ./values/cert_manager_values.yaml
```

```bash
kubectl apply -f ./k8s/cluster_issuer.yaml --namespace basic
```

## Deploy application

```bash
kubectl apply -f ./k8s/configmap.yaml --namespace basic
```

```bash
kubectl apply -f ./k8s/webapp_1.yaml --namespace basic
```

```bash
kubectl apply -f ./k8s/webapp_2.yaml --namespace basic
```

## Deploy ingress

```bash
kubectl apply -f ./k8s/ingress.yaml --namespace basic
```
