## Infra

### Prerequisites
#### [Docker-compose](https://docs.docker.com/compose/install/)

#### [tflocal](https://github.com/localstack/terraform-local)

 Can be installed with:
```bash
$pip3 install terraform-local
```
#### [awscli](https://docs.aws.amazon.com/es_es/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
#### [awscli-local](https://github.com/localstack/awscli-local)

awscli must be install. Otherwise, the command will not work. Can be installed with:
```bash
$pip3 install awscli-local
```

### Run the app
#### Initialize the emulator
```bash
$docker-compose up
```

Next, we need to create a user to get its [credentials](https://docs.localstack.cloud/references/credentials/). This is the one we are going to use to make the AWS requests and the one Terraform is going to use to create the infrastructure.
> The initiated AWS emulator does not have any but the ROOT user (which is not recommended for any operation other than creating users)

We need to use the local aws cli.  
`$ awslocal iam create-user --user-name <USER_NAME>`

Replace `<USER_NAME>` with the name you want. For example:
```bash
$awslocal iam create-user --user-name sol

{
    "User": {
        "Path": "/",
        "UserName": "sol",
        "UserId": "42djzra41mfrmpb580mu",
        "Arn": "arn:aws:iam::000000000000:user/sol",
        "CreateDate": "2024-03-18T23:44:01.131000+00:00"
    }
}
```

Next, we create credentials for this new user  
`$awslocal iam create-access-key --user-name <USER_NAME>`

```bash
$awslocal iam create-access-key --user-name sol

{
    "AccessKey": {
        "UserName": "sol",
        "AccessKeyId": "LKIAQAAAAAAADRGEVZB4",
        "Status": "Active",
        "SecretAccessKey": "TzZ01rpFK3hpS6TsxLlvPf/gaQNUYC8jZhb4bwcj",
        "CreateDate": "2024-03-18T23:47:05+00:00"
    }
}
```
> These aren't actual AWS credentials you can use to access a real aws account so there is not an actual issue sharing them. But we still develop the infra with terraform as if they were to keep the good practices :)

Save these somewhere safe as terraform will ask for them later.  

#### Initialize the infra
> To build the infra we are also going to use the local terraform command `tflocal`

First, run the `tflocal init`. This command initializes the necessary dependencies.
Then, we can run the `tflocal plan` command to view the changes terraform is going to apply.
For now, there are no resources to create so the result is the following:
```bash
$tflocal plan

var.access_key
  Enter a value: "LKIAQAAAAAAADRGEVZB4"

var.secret_key
  Enter a value: "TzZ01rpFK3hpS6TsxLlvPf/gaQNUYC8jZhb4bwcj"


No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are
needed.
```
> The credentials had to be added here, as they are not set in the terraform configuration (for now). The can be exported as env variables though.
If there were resources to create, the command to be used would be `tflocal apply`.

### Following steps
* Persist IAM roles
* Create resources
* Separate tf declarations in different files

### Resources
- [Localstack containers](https://www.localstack.cloud/)
- [Localstack with docker-compose](https://docs.localstack.cloud/getting-started/installation/#starting-localstack-with-docker-compose)
- [Localstack with Terraform](https://docs.localstack.cloud/user-guide/integrations/terraform/)

