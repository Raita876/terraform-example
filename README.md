# Terraform

# How to use

```shell
$ cat .env
export AWS_PROFILE="xxxxxx"
export IAM_ROLE_ARN="arn:aws:iam::xxxxxxxxxxxx:role/xxxxxx"
$ make plan
$ make apply
$ make destroy
```