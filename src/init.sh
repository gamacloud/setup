n (){
    echo "\n"
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root to continue!"
  enter
#   exit
fi

# Modifying DNS config
n
echo "1. Modifying DNS Config at /etc/NetworkManager/NetworkManager.conf to resolve CoreDNS Issue"
echo "\nYou will be redirected to vim, please comment out 'dns=dnsmasq'\n"
# sudo vim /etc/NetworkManager/NetworkManager.conf < `tty` > `tty`
# sudo service network-manager restart
read -p "Press enter to continue..."
n
echo "Disabling the resolvconf mechanism for updating resolv.conf and just use a static resolv.conf file.."
# sudo rm -f /etc/resolv.conf
# sudo echo "nameserver 8.8.4.4" > /etc/resolv.conf
# sudo echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# Install Docker
n
echo "2. Installing Docker..."
echo "Getting required files"
apt-get update
apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
apt-get update && apt-get install docker-ce=18.06.2~ce~3-0~ubuntu

echo "Configuring Docker Service..."
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

echo "Restarting Docker Service..."
# Restart docker.
systemctl daemon-reload
systemctl restart docker
read -p "Press enter to continue..."

# Install Kubeadm
n
echo "3. Installing Kubeadm..."
echo "Getting required files"
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
echo "Installing Kubeadm Elements"
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Init Kubernetes
n
echo "4. Init Kubernetes"
sudo kubeadm init --apiserver-advertise-address=192.168.191.55 --pod-network-cidr=10.244.0.0/16 > $(pwd)/kubeadm_init.log
n
echo "Configuring Kubectl Command"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
n
echo "SAVE THE TOKEN OF CERT KUBEADM"
read -p "Press enter to continue..."
echo "Are you sure already save them?"
read -p "Press enter to continue..."

# Install Kubernetes CNI
n
echo "5. Installing Kubernetes CNI; Using Flannel..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml
