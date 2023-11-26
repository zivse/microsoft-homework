How to run:
----

1. `terraform init`
2. `terraform plan`
3. `terraform apply`
4. after creating the cluster, it will fail because kubeconfig is not defined well
5. run `echo "$(terraform output kube_config)" > ~/.kube/azurek8s`
6. remove the `EOF` inside the file `~/.kube/azurek8s`
7. run `export KUBECONFIG=~/.kube/azurek8s`
8. again run plan and apply with terraform

