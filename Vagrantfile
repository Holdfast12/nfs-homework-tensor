MACHINES = {
    :webserver => {
        :box_name => "generic/centos7",
        :ip_addr => '192.168.1.2',
        :script => './webserver.sh'
    },
    :nfsserver => {
        :box_name => "generic/centos7",
        :ip_addr => '192.168.1.3',
        :script => './nfsserver.sh'
    },
}
 

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |box|
        config.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s
        box.vm.network "private_network", ip: boxconfig[:ip_addr], netmask: "255.255.255.0", virtualbox__intnet: "tensor"
        box.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--memory", "512"]
        end
        box.vm.provision "shell", inline: <<-SHELL
          sudo yum install -y nfs-utils
          echo -en "192.168.1.2 web-server\n192.168.1.3 nfs-server\n\n" | sudo tee -a /etc/hosts
          SHELL
        box.vm.provision "shell", path: boxconfig[:script]
    end
  end
end
