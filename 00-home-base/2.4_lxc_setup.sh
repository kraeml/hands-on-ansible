#/bin/bash 
# set -x

for i in ais-bashy web1 web2 db playbooks; do
	sudo lxc-create -n ${i} -t ubuntu
	sudo lxc-update-config -c /var/lib/lxc/${i}/config
	sudo lxc-start -n ${i}
	echo "Wait for comming up" ${i}
	sleep 5
	if [ $i = ais-bashy ] ; then
		ip=$(sudo lxc-ls --fancy | grep 'ais-bashy' | cut -d '-' -f 3 | tr -d ' ')
		ansible -i localhost, -m shell -a 'ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N "" creates=~/.ssh/id_rsa' --connection=local localhost
		echo $ip
		mkdir ~/.ssh || true
		ssh-keyscan -H $ip >> ~/.ssh/known_hosts
		echo ${ip}
		echo "ubuntu\n\n" | ansible-playbook -i ${ip}, ../02-playbooks/00-simple-playbook-examples/prepare_ansible_target.yml -u ubuntu -k --ask-sudo-pass
	fi
done
sudo lxc-ls --fancy
