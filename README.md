# aks-terraform

## [Project](https://github.com/RustyTake-Off/projects)

Create an Aks cluster and a K8s deployment with cert-manager.

## How to use

Clone this repository.

```bash
git clone https://github.com/RustyTake-Off/aks-terraform.git
```

Modify the variables in <b>variables.tf</b> file.

```bash
terraform -chdir="./infra" plan
```

```bash
terraform -chdir="./infra" apply
```
