# This folder contains IaaC for Openstack

## Important notes

1. Terraform state is kept in our project on [HCP Cloud](https://app.terraform.io/app/weedesign/workspaces/WeeDesign-Policy-Controller), before starting any work on this repository, ask @socz3qqq for access to the project
2. Infrastructure is devided into several components
    1. core --> contains a network with a VM used as an access point to the whole cluster. All further operations should be performed on this machine. The justification for this architectural decision are security concerns (the less machines exposed to public network means more potential weak spots) and the lack of public IP addressess
    2. clusters -> contain kubernetes cluster configurations for certain scenerios. Terraform on from this folder should be run only from the access machine

## How to use?

1. Install terraform on your machine
2. Login to HCP Cloud using `terraform login` in order to let terraform get the state file.
3. Run `terraform init` in the desired directory
4. Make desired changes to the .tf files
5. Run `terraform plan` to see what terraform will try to do
6. RUn `terraform apply` to make actual changes to the infrastructure and update the state
