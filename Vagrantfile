Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.network :forwarded_port, guest: 8983, host: 4983
  config.vm.network :forwarded_port, guest: 5432, host: 4432
  # config.vm.network :private_network, ip: '192.168.50.50'
  # config.vm.synced_folder '.', '/opt/meta'
  config.vm.provider :virtualbox do |v, _|
    v.memory = 1024
  end
  config.vm.provision 'shell', inline: <<-SHELL
    sudo date > /etc/vagrant_provisioned_at
    apt-get update
    apt-get upgrade
    apt-get -y -q install git-core make gcc default-jdk
  SHELL
  config.vm.provision :shell, path: 'provision/postgres.sh',      name: 'PG'
  config.vm.provision :shell, path: 'provision/redis.sh',         name: 'Redis'
  config.vm.provision :shell, path: 'provision/solr.sh',          name: 'Solr',     privileged: false
  # config.vm.provision :shell, path: 'provision/install_rvm.sh',   name: 'RVM',      privileged: false
  # config.vm.provision :shell, path: 'provision/install_ruby.sh',  name: 'Ruby',     privileged: false, args: '2.3.4'
  # config.vm.provision :shell, path: 'provision/meta.sh',          name: 'Meta App', privileged: false
end