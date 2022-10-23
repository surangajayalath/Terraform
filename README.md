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

Terraform state - blueprint of infrastructure define by terraform.
HCL - Declarative Language
Resource/Providers - S3,EC2,DB,GCP,Azure
random pet - 

### HCL Syntax
```
<block> <parameters> {
  key1 = value1
  key2 = value2
}
```
##### Example:-
```
resource "aws_instance" "webserver" {
  ami = "ami-37fnd9m3nckdjd4d"
  instance_type = "t2.micro"
}
```
![Screenshot 2022-10-23 at 9 26 02 PM](https://user-images.githubusercontent.com/56903228/197402381-2f49386d-2847-4abe-8c6e-71e19526dbf3.png)



write 
- init - check configuration file & initializing .tf files
  - while download & install plugins for the provides   
plan - review(show similar output)
apply - show execution plan
show - show resource details.

### Files
![Screenshot 2022-10-23 at 10 11 19 PM](https://user-images.githubusercontent.com/56903228/197404477-0176db09-5982-438d-a156-287155c3ae0e.png)

### Variables
![Screenshot 2022-10-23 at 11 04 52 PM](https://user-images.githubusercontent.com/56903228/197406894-544ce8dc-7512-45c3-9f54-99c76ab82d76.png)

##### Variable Block
![Screenshot 2022-10-23 at 11 06 01 PM](https://user-images.githubusercontent.com/56903228/197406946-74273a8e-e16c-42ba-b82c-c2a30b0366cb.png)

##### Variable Data types
![Screenshot 2022-10-23 at 11 06 56 PM](https://user-images.githubusercontent.com/56903228/197406988-a62b40c6-ce82-4f53-aee6-6224d1855b93.png)

##### List
![Screenshot 2022-10-23 at 11 08 01 PM](https://user-images.githubusercontent.com/56903228/197407034-7f43a692-627b-44ec-aca4-c47cbf3df28e.png)

##### Map
![Screenshot 2022-10-23 at 11 09 01 PM](https://user-images.githubusercontent.com/56903228/197407082-ec5683a7-3b55-403e-8ca9-3d1c69645eb7.png)

##### Map of a Type
![Screenshot 2022-10-23 at 11 10 22 PM](https://user-images.githubusercontent.com/56903228/197407144-b1b0ba60-9cf3-45b5-9daf-75e370c86693.png)

##### Set
- Can't duplicate values here
![Screenshot 2022-10-23 at 11 11 26 PM](https://user-images.githubusercontent.com/56903228/197407189-a63384ce-9b96-437d-9f82-58c02e9471a5.png)

##### Objects
![Screenshot 2022-10-23 at 11 13 06 PM](https://user-images.githubusercontent.com/56903228/197407246-4de29653-db46-4059-ba2b-c301b3add20c.png)

##### Tuples
- Same as List
![Screenshot 2022-10-23 at 11 14 16 PM](https://user-images.githubusercontent.com/56903228/197407303-afbd71dd-5b14-4bf6-84a9-a86cd2314521.png)































