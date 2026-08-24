Vagrant.configure("2") do |config|
  config.vm.box = "cloud-image/ubuntu-24.04"
  config.vm.box_version = "20260814.0.0"

  nodes = [
    { name: "k8s-master", ip: "192.168.56.10", cpu: 6, mem: 8192 },
    { name: "k8s-worker-1", ip: "192.168.56.11", cpu: 4, mem: 4096 },
    { name: "k8s-worker-2", ip: "192.168.56.12", cpu: 4, mem: 4096 }
  ]
  nodes.each do |node|
    config.vm.define node[:name] do |subconfig|
      subconfig.vm.hostname = node[:name]
      subconfig.vm.network "private_network", ip: node[:ip]

      subconfig.vm.provider "virtualbox" do |vb|
        vb.name = node[:name]
        vb.cpus = node[:cpu]
        vb.memory = node[:mem]
        vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxvga"]
      end
    end
  end
end
