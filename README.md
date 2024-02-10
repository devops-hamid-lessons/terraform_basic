# Terraform + AWS + EC2 (basic)

This is an example basic Terraform project, demonstrating how to write a Terraform playbook in order to automatically provision an aws ec2 machine and execute an initial script inside it.
## Requirement

Requirement         | Specification
------------------- | ----------------------
OS                  | Ubuntu 22.04
Language            | Terraform


## How to use
- Make sure that you have already installed terraform on you machine.
- Make sure that you have configured aws credentials on you machine, and you can connect to your account.
- Clone this project, adjust variables inside `terrrafromVars.tfvars` file, and then simply run:

```bash
terraform init
terraform apply -auto-approve
```
- Note that it is assumed that you have already created aws-ssh-key pairs named `server-key`. 
- You can also use the keys created by your self and tell Terraform to load and use the related public-key. This line is commented currently. To use uncomment line #163 and also provide the location of your public-keu inside the var file.
- Output param name `myapp_server_ip` will print the IP address of machine.
- This Terraform script will execute `initiaScript.sh` once machine is ready to install `docker` and `docker-compose`. You can change it as desire.  