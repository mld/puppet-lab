# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

domain = 'lab'

# Add flag :cm => 1 if you want a puppet run at first boot.
nodes = [
  {:hostname => 'puppet', :ip => '192.168.50.10',  :box => 'ubuntu/trusty64',  :cm => 'shell', :ram => 512},
  {:hostname => 'node1',  :ip => '192.168.50.101', :box => 'ubuntu/trusty64',  :cm => 'shell' },
  {:hostname => 'node2',  :ip => '192.168.50.102', :box => 'ubuntu/trusty64',  :cm => 'shell' },
]

# Begin configuring our puppet lab network
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]

      if node[:fwdhost]
        node_config.vm.network :forwarded_port, guest: node[:fwdguest], host: node[:fwdhost]
      end

      memory = node[:ram] ? node[:ram] : 256;
      node_config.vm.provider :virtualbox do |vb|
        vb.customize [
          'modifyvm', :id,
          '--name', node[:hostname],
          '--memory', memory.to_s
        ]
      end

      if node[:cm] == "puppet"
        node_config.vm.provision :puppet do |puppet|
          puppet.manifests_path = 'bootstrap/manifests'
          puppet.module_path = 'bootstrap/modules'
        end
      elsif node[:cm] == "shell"
        node_config.vm.provision "shell", path: "bootstrap/bootstrap.sh"
      end
    end
  end
end

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "site.pp"
  # end
