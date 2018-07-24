Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.network :forwarded_port, guest: 8983, host: 4983
  config.vm.network :forwarded_port, guest: 5432, host: 4432
  config.vm.network :forwarded_port, guest: 6379, host: 6379
  config.vm.provider :virtualbox do |v, _|
    v.memory = 1024
  end
  config.vm.provision 'shell', inline: <<-SHELL
    sudo date > /etc/vagrant_provisioned_at
    apt-get update
    apt-get upgrade
    apt-get -y -q install git-core make gcc default-jdk
  SHELL
  config.vm.provision :shell, path: 'provision/postgres.sh'
  config.vm.provision :shell, path: 'provision/redis.sh'
  config.vm.provision :shell, path: 'provision/solr.sh', privileged: false
end