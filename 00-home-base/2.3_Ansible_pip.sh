   sudo apt-get install python-pip
   sudo pip install ansible
   LC_ALL=C sudo pip install ansible
   ansible --version
OR
   sudo apt-get install python3 virtualenv
   mkdir ansible3
   sudo locale-gen de_DE.UTF-8
   virtualenv -p python3 ansible3
   cd ansible3/
   source bin/activate
   sudo apt-get install -y libffi-dev libssl-dev cowsay sshpass python3-dev 
   pip install ansible
   which ansible
   ansible -m ping localhost
OR
   apt-cache policy ansible
   sudo apt-get install ansible
