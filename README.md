# aks-terraform

## [Projects](https://github.com/RustyTake-Off/projects)

[Mini Project] - Create an Aks cluster and a K8s deployment with Nginx, Cert-Manager and Let's Encrypt.

## The how?

Clone this repository.

```bash
git clone https://github.com/RustyTake-Off/aks-terraform ./aks-terraform
```

Look around all the folders, files and change things to your own liking. After that run the terraform commands.

Initialize terraform with the init command and let it download the necessary dependencies.

```bash
terraform -chdir="./infra" init
```

Then run the plan and check what will terraform create. It may throw some errors if something is wrong.

```bash
trraform -chdir="./infra" plan
```

When everything is correct and you are satisfied use the apply command and wait for your resources to be deployed. It can take around 8 - 10 minutes.

```bash
terraform -chdir"./infra" apply
```

When deployment is done look around your [Azure Portal](https://portal.azure.com) for created resources.

If you are done, destroy the deployment with the below command.

```bash
terraform -chdir"./infra" destroy
```
