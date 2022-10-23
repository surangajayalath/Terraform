### Terraform

- Initialize the directory - When you create a new configuration — or check out an existing configuration from version control — you need to initialize the directory with terraform init
- In this phase terraform initializes the project and identifies the provides to be used for the target environment
```
terraform init
```
- The terraform fmt command automatically updates configurations in the current directory for readability and consistency.
```
terraform fmt
```
- You can also make sure your configuration is syntactically valid and internally consistent by using the terraform validate command.
```
terraform validate
```
- Plan phase terraform drafts a plan to get to the target state
```
terraform plan
```
- Apply the configuration now with the terraform apply command. 
- makes the necessary changes required on the target environment to bring it to the desired state.
```
terraform apply
```
- Inspect state
```
terraform show
```
- Terminate Service
```
terraform destroy
```
- Show outputs
```
terraform output
```
- Show state list
```
terraform state list
```
