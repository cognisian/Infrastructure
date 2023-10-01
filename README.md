# Instructions

## Instantiate GCE
Terraform is used to manage the Infrastructure

Update the Google Cloud platform CLI and login to get token
Token expired whne seeing error message like 'oauth2: cannot fetch token: 400 Bad Request'
or 'oauth2: "invalid_grant" "Bad Request"'
`gcloud components update`
`gcloud auth login`

`terraform init -upgrade`
`terraform plan -var-file=secrets.tfvars`

IF the infrastructure update requires deleting then haave to remove the
instance delete prevention flag.
Infrastructure is replaced when the above terraform plan returns:
`google_compute_instance.webservers[0] must be *replaced*`
THEN the following command needs to be run
`gcloud compute instances update webserver --no-deletion-protection`

Then to APPLY the changes
`terraform apply -var-file=secrets.tfvars`

AFTER apply then the deletion-prevention flage should be set n new instance
`gcloud compute instances describe webserver | grep deletion`

AFTER apply the output will show the IP addresses this is needed
for SSH

SSH into instance to verify accessible
`ssh cognisian`

.ssh/config:
Host cognisian 
    HostName IP  FROM TERRAFORM
    Port 22
    User youknowwhoitis
    UserKnownHostsFile /dev/null
    CheckHostIP no
    StrictHostKeyChecking no
    IdentityFile ~/.ssh/youknowwhoitis-key

## Install Software
Ansible is ued to manage the software stack

Update
`ansible-playbook -b -i inventory/gce_inventory.yaml playbook.yml`

## Load Web Site
We have web site set in GitHub as an Action to build and deploy to GCP
To trigger the build/deploy then have to check in a change

First generate the website from the ResumeGenerator project

`cd <root>/ResumeGenerator`
`./generate_resume.py -output=~/<root>/website/output/pages/resume.html`

