#!/bin/bash

-set x

# Path for prepare playbook
prepare=~/ais/hands-on-ansible/02-playbooks/00-simple-playbook-examples/prepare_ansible_target.yml

# Cnerate containers
for i in ais-bashy web1 web2 db playbooks; do
	sudo lxc-create -n ${i} -t ubuntu && \
	# Remove legacy configuration keys \
	sudo lxc-update-config -c /var/lib/lxc/${i}/config && \
	# Start container \ 
	sudo lxc-start -n ${i} && \
	# Prepare ais-bashy \
	if [[ ${i} == "ais-bashy" ]]; then
		echo "Wait for comming up"
		sleep 5
		# Get ip
		ip=$(sudo lxc-ls --fancy | grep ${i} | cut -d '-' -f 3 | tr -d ' ')
		# Remove host key for ip
		ssh-keygen -R ${ip}
		# Add ip into known_hosts
		ssh-keyscan -H ${ip} >> ~/.ssh/known_hosts
		# Setup ssh-key for user
		ansible -i localhost, -m shell -a 'ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N "" creates=~/.ssh/id_rsa' --connection=local localhost
		# Run prepare playbook
		ansible-playbook -i ${ip}, -u ubuntu -k --ask-sudo-pass ${prepare}
	fi
done
sudo lxc-ls --fancy
