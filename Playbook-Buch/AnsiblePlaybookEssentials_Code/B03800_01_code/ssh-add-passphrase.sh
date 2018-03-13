#!/usr/bin/expect -f
spawn ssh-add /home/vagrant/.ssh/id_rsa
expect "Enter passphrase for /home/vagrant/.ssh/id_rsa:"
send "geheim\n";
interact
