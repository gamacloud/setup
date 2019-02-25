enter (){
  read -p "Press enter to continue..."
}

n (){
  echo "\n"
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root to continue!"
  enter
  exit
fi

# Install Helm
echo "1. Installing Helm"
n
cd /tmp
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > install-helm.sh
chmod u+x install-helm.sh
sudo ./install-helm.sh
# Init Helm
echo "2. Initialize Helm"
n
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
# Configure Helm
echo "3. Configuring Helm Repositories"
n
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
# Helm Install
echo "4. Installing Helm Chart"
n
echo "Get ready to install chart"
enter
helm install --name hadoop \
--set persistence.nameNode.enabled=true \
--set persistence.nameNode.storageClass=standard \
--set persistence.dataNode.enabled=true \
--set persistence.dataNode.storageClass=standard \
stable/hadoop