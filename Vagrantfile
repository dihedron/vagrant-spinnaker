# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname = "spinnaker"
  config.vm.define "spinnaker"
  # config.vm.box_check_update = false
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "192.168.33.11"
  config.vm.provider "virtualbox" do |vb|
	vb.name = "spinnaker"
    vb.memory = "2048"
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end
  config.vm.provision "shell" do |sh|
    sh.path = "bootstrap.sh"
    sh.args   = ["kubernetes"] # or "openstack"
  end  
  config.vbguest.auto_update = true
end
