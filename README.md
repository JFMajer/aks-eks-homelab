# aws-eks-homelab

./deploy_eks_cluster.sh

./deploy_eks_nodegroup.sh

eksctl delete cluster --name cluster-00

eksctl delete nodegroup --cluster=cluster-00 --name=workers-managed

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install --generate-name prometheus-community/prometheus

eksctl create addon --name aws-ebs-csi-driver --cluster cluster-00 --service-account-role-arn arn:aws:iam::<account_id>:role/AmazonEKS_EBS_CSI_DriverRole --force

eksctl create cluster -f cluster.yaml