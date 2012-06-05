# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

  config.vm.define :server do |server|
    server.vm.box = "lucid32"
    #server.vm.box_url = "http://localhost/~pmorillon/vagrant_boxes/debian-squeeze-x64_puppet-2.6.9.box"
    server.vm.box_url = "http://files.vagrantup.com/lucid32.box"
    server.vm.network :hostonly, "192.168.1.10"
    server.vm.forward_port 3306, 13306
    server.vm.share_folder "puppet_modules", "/srv/puppet_modules/oar", "."
    server.vm.provision :puppet, :pp_path => "/srv/vagrant-puppet", :options => ["--modulepath", "/srv/puppet_modules"] do |puppet|
      puppet.manifests_path = "vagrant/manifests"
      puppet.manifest_file = "server.pp"
    end
  end

  config.vm.define :node1 do |node1|
    node1.vm.box = "lucid32"
    #node1.vm.box_url = "http://localhost/~pmorillon/vagrant_boxes/debian-squeeze-x64_puppet-2.6.9.box"
    node1.vm.box_url = "http://files.vagrantup.com/lucid32.box"
    node1.vm.network :hostonly, "192.168.1.101"
    node1.vm.share_folder "puppet_modules", "/srv/puppet_modules/oar", "."
    node1.vm.provision :puppet, :pp_path => "/srv/vagrant-puppet", :options => ["--modulepath", "/srv/puppet_modules"] do |puppet|
      puppet.manifests_path = "vagrant/manifests"
      puppet.manifest_file = "node.pp"
    end
  end

  # To add several nodes, use these IP addresses :
  # node1 : 192.168.1.101
  # node2 : 192.168.1.102
  # node3 : 192.168.1.103

end

