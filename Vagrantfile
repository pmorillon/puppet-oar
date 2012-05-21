# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

  #facters = { "modulepath" => "../module-0" }

  config.vm.define :server do |server|
    server.vm.box = "oar"
    server.vm.box_url = "http://localhost/~pmorillon/vagrant_boxes/debian-squeeze-x64_puppet-2.6.9.box"
    server.vm.network :hostonly, "192.168.1.10"
    server.vm.share_folder "puppet_modules", "/tmp/puppet_modules/oar", "."
    server.vm.provision :puppet, :options => ["--modulepath", "/tmp/puppet_modules"] do |puppet|
      puppet.manifests_path = "vagrant/manifests"
      puppet.manifest_file = "server.pp"
    end
  end

end

