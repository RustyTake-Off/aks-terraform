# K8s

Remember to always look around the folders, files and to modify things to your own liking.

## Get Aks credentials

Run the get-credentials command to get the KubeConfig.

```bash
az aks get-credentials -g rgaztfpro02 -n aksaztfpro02
```

## Create namespace for the webapp

```bash
kubectl create namespace webapp
```

## Install Nginx Ingress with Helm

When installing check what is the latest version of the ingress at [ArtifactHub - Nginx](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx) and use the **Load Balancer IP** from the earlier terraform deployment.

```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress --create-namespace --version 4.5.2 -- set controller.service.loadBalancerIP=">LB IP HERE<"
```

## Install Cert-manager and apply cluster issuer

Modify the email field in the **cluster_issuer_prod.yaml, cluster_issuer_staging.yaml** files and run the celow command.

Check the Cert-Manager cersion on [ArtifactHub - Cert-Manager](https://artifacthub.io/packages/helm/cert-manager/cert-manager)

```bash
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.11.0 --set installCRDs=true
```

After that apply the ClusterIssuers.

```bash
kubectl apply -f ./k8s/cluster_issuer_staging.yaml
```

```bash
kubectl apply -f ./k8s/cluster_issuer_prod.yaml
```

## Deploy application

Now deploy the [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/) which the webapps require. Then apply the webapps themselves with their [services](https://kubernetes.io/docs/concepts/services-networking/service/) and [HorizontalPodAutoscalers](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).

```bash
kubectl apply -f ./k8s/configmap.yaml --namespace webapp
```

```bash
kubectl apply -f ./k8s/webapp_1.yaml --namespace webapp
```

```bash
kubectl apply -f ./k8s/webapp_2.yaml --namespace webapp
```

## Deploy ingress

And lastly the [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).

```bash
kubectl apply -f ./k8s/ingress.yaml --namespace ingress
```
