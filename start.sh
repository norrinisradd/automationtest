#!/bin/bash
chmod 400 dockerhosts.pem
eval $(ssh-agent -s)
ssh-add dockerhosts.pem
ansible-playbook deploy.yml
