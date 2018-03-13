

Vagrant.configure(2) do |config|

  # Falls vbguest-plugin bitte Guest nachladen
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = true
  end

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
    # Customize the amount of memory on the VM:
    vb.memory = "768"
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    vb.linked_clone = true
  end

  #config.vm.box = "ubuntu_de_201610051341"
  config.vm.box = "kraeml/xenial-64-de"

  # config.ssh.insert_key = false

  config.vm.define "ctl" do | ctl |
    ctl.vm.box = "kraeml/ubuntu_de"
    ctl.vm.hostname = "ctl"
    # Bitte in hosts eintragen.
    # 192.168.5.60 ubuntu_ais ubuntu_ais
    # Somit kann mit ping ubuntu_ais bzw. http://ubuntu_ais
    # aufgerufen werden.
    ctl.vm.network "private_network",
     ip: "192.168.5.60"

    # Das Gruene Netzwerk
    ctl.vm.network "private_network",
     ip: "192.168.60.254",
     virtualbox__intnet: "Gruen"

    # DHCP und WWW über das lokale Netz
    # Die DHCP Einstellungen werden übernommen
    ctl.vm.network "public_network",
     use_dhcp_assigned_default_route: true

    # ctl.vm.provision "shell", path: "./provision/ctl/sshd_config.sh"
    ctl.vm.provider "virtualbox" do |vb|
      vb.name = "ubuntu_ais_ctl.rdf"
    end
    ctl.vm.synced_folder "projects/", "/home/vagrant/projects"
  end

  config.vm.define "loadbalancer" do | lb |
    lb.vm.hostname = "lb"
    #Das Gruene Netzwerk
    lb.vm.network "private_network",
     ip: "192.168.60.2",
     virtualbox__intnet: "Gruen"

    lb.vm.provider "virtualbox" do |vb|
      vb.name = "ubuntu_ais_lb.rdf"
    end
  end

  config.vm.define "web1" do | web1 |
    web1.vm.hostname = "web1"
    #Das Gruene Netzwerk
    web1.vm.network "private_network",
     ip: "192.168.60.11",
     virtualbox__intnet: "Gruen"

    web1.vm.provider "virtualbox" do |vb|
      vb.name = "ubuntu_ais_web1.rdf"
    end
  end

  config.vm.define "web2" do | web2 |
    web2.vm.hostname = "web2"
    #Das Gruene Netzwerk
    web2.vm.network "private_network",
     ip: "192.168.60.12",
     virtualbox__intnet: "Gruen"

    web2.vm.provider "virtualbox" do |vb|
      vb.name = "ubuntu_ais_web2.rdf"
    end
  end

  config.vm.define "web3" do | web3 |
    web3.vm.hostname = "web3"
    #Das Gruene Netzwerk
    web3.vm.network "private_network",
     ip: "192.168.60.13",
     virtualbox__intnet: "Gruen"

    web3.vm.provider "virtualbox" do |vb|
      vb.name = "ubuntu_ais_web3.rdf"
    end
  end
  # Die erste Datenbank
  config.vm.define "db1" do | db1 |
    #db1.vm.box = "debian/jessie64"
    db1.vm.hostname = "db1"
    # Das Gruene Netzwerk
    db1.vm.network "private_network",
     ip: "192.168.60.21",
     virtualbox__intnet: "Gruen"

    db1.vm.provider "virtualbox" do |vb|
      vb.name = "ubuntu_ais_db1.rdf"
    end
  end

  # Die zweite Datenbank
  config.vm.define "db2" do | db2 |
    #db2.vm.box = "opscode_centos-6.5-i386"
    #db2.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5-i386_chef-provisionerless.box"
    #db2.vm.box = "centos/7"
    db2.vm.hostname = "db2"
    # Das Gruene Netzwerk
    db2.vm.network "private_network",
     ip: "192.168.60.22",
     virtualbox__intnet: "Gruen"

    db2.vm.provider "virtualbox" do |vb|
      vb.name = "ubuntu_ais_db2.rdf"
    end
  end
end
