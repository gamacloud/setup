enter (){
    read -p "Press enter to continue..."
}

n (){
    echo "\n"
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root to continue!"
  enter
#   exit
fi

enter
echo "You will turn this machine to Gamacloud Kubernetes Engine!"
echo "There are 3 main component"
echo "1. Initialize Kubernetes"
echo "2. Joining Nodes"
echo "3. Deploying Apps; this case is Hadoop WIth Zeppelin"
enter
n
echo "Let's Begin the Initialization of Kubernetes"
enter
./src/init.sh > $(pwd)/init.log
enter
n
echo "Let's Begin Joining Nodes"
enter
echo "the command looks like this # kubeadm join 10.6.128.190:6443 --token 6be4jy.2e1ootgt34il990m --discovery-token-ca-cert-hash sha256:1191a5bc837b47186a60208193ea77b32bf341d3f004126457327cbad0182aa0"
echo "Go to your nodes, and join them to main cluster!"
enter
n
echo "Let's Deploy Hadoop and Zeppelin!"
enter
./src/deploy.sh > $(pwd)/deploy.log
n
enter
echo "Finished!"