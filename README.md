# Automation Proof of Concept
Using Ansible to deploy a load balanced containizered web application to AWS

## Requirements
**AWS Keypair** - In this example I am using keypair `dockerhosts`, if you choose another name you will need to update references in vars.yml (`ec2_keypair`), start.sh (pem filename), and the Vagrantfile (pem filename).

**AWS IAM User** - Please setup a new IAM user with programatic access and add them to the Poweruser group, you will need to supply this user's access key and secret in vars.yml.

**SSH Access to AWS** - A firewall will cause an issue if SSH out is not open.
## Assumptions
User is not behind a web proxy as this may affect the testing and verification of the solution since the access list (security group) is created dynamically using checkip.amazonaws.com.
## Deployment Instructions
**Option 1** (Preferred) - Deploy using a machine running Vagrant/Virtualbox.  I have included a Vagrantfile that will provision a Centos VM with all of the requirements needed to deploy to AWS via Ansible.  Simply clone repo to the Vagrant host, update vars.yml file with access/secret keys and copy your pem (dockerhosts.pem by default) file to the cloned repo directory, then run `vagrant up` (it might take a while to download the centos/7 box file if you do not already have it).   Once Vagrant is up, run `vagrant ssh`, once you are finally in the VM run `./start.sh`.  Once completed, the playbook will send out a debug message with the FQDN of the new ELB, this process may display the wrong FQDN if you already have ELBs connected to the AWS account you are testing with.

**Option 2** - Deploy using a machine that already has Ansible/Boto/Boto3 installed, clone repo to the machine, update vars with keypair name and access/secret for IAM user, then run `ansible-playbook deploy.yml`  Once completed, the playbook will send out a debug message with the FQDN of the new ELB, this process may display the wrong FQDN if you already have ELBs connected to the AWS account you are testing with. NOTE: The associated PEM file for the keypair should already be loaded into your ssh-agent or the script will fail.

## Observations
This was my first time working with dynamic inventories in AWS using Ansible and I really enjoyed it.  All instances will have Cloudwatch detailed monitoring enabled by the playbook. The default value for `instance_count` is 3 in vars.yml, I would encourage you to run through the playbook with that value as is initially.  Once the 3 instances are up and the playbook has completed, change `instance_count` to a higher number and rerun script (or the playbook directly if you went with option 2).  It will dynamically grow the cluster to the new size including adding the new instances to the ELB.  The playbook will also shrink the cluster if a lower number for `instance_count` is specified in a later run. This playbook could easily deploy other containizered web apps hosted on Docker Hub by changing `image_name` and `docker_port` in vars.yml or deploy to another region of AWS by changing `ec2_region`.   Lastly the playbook could be modified to use a Docker Trusted Registry (or Amazon ECR) instead of Docker Hub to deploy trusted images.

One last note, when provisioning a "large" cluster (largest I tried was 9) you may have a single host fail a step (pypi.doubanio.com timed out on me as example), if so simply run the script or playbook again and it will remediate the bad instance(s).  I have also see this occur at the **Add EC2 instances as known hosts**, rerunning the script or playbook will also fix this.
