for provider and network,
learn the terraform documention at https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

COUNTING_SERVICE_URL=http://<COUNTING-INTERNAL-ALB-DNS>
Terraform knows that DNS name automatically:aws_lb.counting.dns_name
to rewrite /etc/dashboard.env.

#Run Terraform
#From the project directory:
#bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
yes

#Verify after deployment
terraform output
Then open:
http://<dashboard_alb_dns>

#To destroy all of this:
terraform destroy
terraform apply

in condition jumphost to private instances permission denied,
from mac

eval "$(ssh-agent -s)"
ssh-add ~/Downloads/hsu-master-2.pem
ssh-add -l

inside the jump host 
ssh-add -l

Always check mac address and update jump-hostsg groups of cidr_blocks
curl https://checkip.amazonaws.com - to get mac address for ssh jumphost

sudo nano /etc/dashboard.env
sudo systemctl restart dashboard
sudo systemctl status dashboard

sudo cp ~/team8-root-ca.crt /etc/pki/ca-trust/source/anchors
sudo update-ca-trust