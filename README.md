# AWS_Webserver_ALB_ASG_terraform

Sample code to create a bunch of `webservers` behind a Load Balancer (`ALB`) with an Auto scaling group (`ASG`) 

### Deploy Webservers
We are using `ASG` to launch a cluster of EC2 Instances, monitoring the health of each Instance, replacing failed Instances, and adjusting the size of the cluster in response to load.

ASG distributes the EC2 instances across multiple availability zones

### Deploy a Load Balancer

After deploying the `ASG` you'll have several different servers, each with its own IP address, but you need to give your end users only a single IP to hit, and for this we're going to deploy a load balancer to distribute traffic across your servers and to give your end users a single DNS name which is the the load balancer DNS name

### Note
I have deployed the resources in `ap-south-1(Mumbai)` region.If you want to deploy it in a different region, please update the `region` and `availability zone` variables in vars.tf file.

# Usage

Insert your AWS `access key` & `secret key` as Environment Variables, In this way we're NOT setting them permanently, you'll need to run these commands again whenever you reopen your terminal

```bash
export AWS_ACCESS_KEY_ID=<your access key>
export AWS_SECRET_ACCESS_KEY=<your secret key>
```


```bash
yum -y install git
```



```bash
git clone https://github.com/SumirArora/AWS_Webserver_ALB_ASG_terraform.git
cd AWS_Webserver_ALB_ASG_terraform/

# Downloading the Plugin for the AWS provider
terraform init
```

* See what's Terraform is planning to do before really doing it

```bash
terraform plan
```

* build the Terraform project

```bash
terraform apply
# yes | if you want to proceed
```

* destroy what you've built

```bash
terraform destroy
# yes | if you want to proceed
```
