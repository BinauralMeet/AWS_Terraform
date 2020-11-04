# BinauralMeet AWS

Deploy BinauralMeet AWS infrasture with Terraform. 

#### 0. Install Terraform
Install Terraform using [Homebrew](https://brew.sh/).

1. Install Terraform
```
$ brew install tfenv  # install Terraform version manager
$ tfenv install <Terraform version>
```
2. Verify Terraform installation
```
$ terraform
```

### 1. Terraform Setup
#### 1-1. terraform init
1. Adjust `backend` stanza of `terraform` section so that Terraform stores states in S3 bucket
```
$ vim config.tf
```
3. Run `terraform init`
```
$ terraform init
```

#### 1-2. terraform plan
#### 1-3. terraform apply
#### 1-4. terraform destroy
1. Run `terraform destroy`

```
$ terraform destroy -target <Resource>  # Destroy specific resource
```


## Reference List

- https://www.expeditedssl.com/aws-in-plain-english
- https://www.terraform.io/intro/getting-started/modules.html
- https://www.terraform.io/docs/commands/init.html
- https://www.terraform.io/docs/commands/plan.html
- https://www.terraform.io/docs/commands/apply.html
- https://www.terraform.io/docs/commands/destroy.html
- https://www.terraform.io/docs/enterprise/workspaces/repo-structure.html#directories
