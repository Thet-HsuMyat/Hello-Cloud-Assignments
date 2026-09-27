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

to know alb ip
 dig +short <alb-dns>
 nslookup

 To build binary file
 
EC2 is x86_64, you correctly cross-compiled the Linux binary:
uname -m
# arm64
GOOS=linux GOARCH=amd64 go build -o dashboard-service
file dashboard-service
check -> ELF 64-bit LSB executable, x86-64

Alb testing ./alb-weight-test.sh 1000

 After terraform apply, check 
 1.from the new Dashboard EC2 curl -v https://counting.hsu-team8.io/
 2.We then checked that the running Dashboard process was really using: PORT=9001
COUNTING_SERVICE_URL=https://counting.hsu-team8.io
sudo nano /etc/systemd/system/counting.service
sudo nano /etc/systemd/system/dashboard.service

sudo systemctl daemon-reload
sudo systemctl restart dashboard
sudo systemctl status dashboard