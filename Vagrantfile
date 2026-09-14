Vagrant.configure("2") do |config|
  config.vm.box = "cloud-image/ubuntu-24.04"
  config.vm.box_version = "20260814.0.0"

  nodes = [
    { name: "k8s-master",   ip: "192.168.56.10", cpu: 6, mem: 8192, role: "master" },
    { name: "k8s-worker-1", ip: "192.168.56.11", cpu: 4, mem: 4096, role: "worker" },
    { name: "k8s-worker-2", ip: "192.168.56.12", cpu: 4, mem: 4096, role: "worker" }
  ]

  $common_setup = <<-SCRIPT
    set -e

    echo "===> [1/6] Disabling Swap..."
    swapoff -a
    sed -i '/ swap / s/^/#/' /etc/fstab

    echo "===> [2/6] Configuring kernel modules and sysctl..."
    cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

    modprobe overlay
    modprobe br_netfilter

    cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

    sysctl --system

    echo "===> [3/6] Installing containerd..."
    curl -LO https://github.com/containerd/containerd/releases/download/v2.3.4/containerd-2.3.4-linux-amd64.tar.gz
    tar Cxzvf /usr/local containerd-2.3.4-linux-amd64.tar.gz
    curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
    mkdir -p /usr/local/lib/systemd/system/
    mv containerd.service /usr/local/lib/systemd/system/
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    systemctl daemon-reload
    systemctl enable --now containerd

    echo "===> [4/6] Installing runc and CNI plugins..."
    curl -LO https://github.com/opencontainers/runc/releases/download/v1.5.1/runc.amd64
    install -m 755 runc.amd64 /usr/local/sbin/runc

    curl -LO https://github.com/containernetworking/plugins/releases/download/v1.9.1/cni-plugins-linux-amd64-v1.9.1.tgz
    mkdir -p /opt/cni/bin
    tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.9.1.tgz

    echo "===> [5/6] Installing Kubeadm, Kubelet, Kubectl (v1.37)..."
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gpg

    mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.37/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.37/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

    apt-get update
    apt-get install -y kubelet=1.37.0-1.1 kubeadm=1.37.0-1.1 kubectl=1.37.0-1.1 --allow-downgrades --allow-change-held-packages
    apt-mark hold kubelet kubeadm kubectl

    echo "===> [6/6] Configuring crictl..."
    VERSION="v1.37.0"
    curl -LO "https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz"
    tar -C /usr/local/bin -xzf "crictl-${VERSION}-linux-amd64.tar.gz"
    rm -f "crictl-${VERSION}-linux-amd64.tar.gz"

    crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock
  SCRIPT

  $master_setup = <<-SCRIPT
    set -e
    MASTER_IP="192.168.56.10"

    echo "===> Initializing Kubernetes Master Node..."
    kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=$MASTER_IP --node-name k8s-master

    echo "===> Setting up kubeconfig for vagrant & root users..."
    mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown vagrant:vagrant /home/vagrant/.kube/config

    mkdir -p /root/.kube
    cp -i /etc/kubernetes/admin.conf /root/.kube/config

    echo "===> Installing Calico CNI..."
    kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/calico.yaml

    echo "===> Generating Join Command for Workers..."
    kubeadm token create --print-join-command > /tmp/join.sh
    chmod +x /tmp/join.sh

    kubectl -n kube-system set env daemonset/calico-node IP_AUTODETECTION_METHOD=cidr=192.168.56.0/24
  SCRIPT

  $worker_setup = <<-SCRIPT
    set -e
    echo "===> Waiting for join command from Master..."
    while [ ! -f /tmp/join.sh ]; do
      sleep 5
    done

    echo "===> Joining cluster..."
    bash /tmp/join.sh
  SCRIPT

  nodes.each do |node|
    config.vm.define node[:name] do |subconfig|
      subconfig.vm.hostname = node[:name]
      subconfig.vm.network "private_network", ip: node[:ip]

      subconfig.vm.provider "virtualbox" do |vb|
        vb.name = node[:name]
        vb.cpus = node[:cpu]
        vb.memory = node[:mem]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxvga"]
      end

      subconfig.vm.provision "shell", inline: $common_setup

      if node[:role] == "master"
        subconfig.vm.provision "shell", inline: $master_setup
      else
        subconfig.vm.provision "shell", inline: $worker_setup
      end
    end
  end
end