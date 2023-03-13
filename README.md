# aws-eks-homelab

eksctl create cluster -f cluster.yaml


# Installing EBS CSI Driver

eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster cluster-00 \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole


eksctl create addon --name aws-ebs-csi-driver --cluster cluster-00 --service-account-role-arn arn:aws:iam::<account_id>:role/AmazonEKS_EBS_CSI_DriverRole --force

eksctl get addon --name aws-ebs-csi-driver --cluster cluster-00

# Installing FluentBit

kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml

ClusterName=cluster-00
RegionName=eu-north-1
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
kubectl create configmap fluent-bit-cluster-info --from-literal=cluster.name=${ClusterName} --from-literal=http.server=${FluentBitHttpServer} --from-literal=http.port=${FluentBitHttpPort} --from-literal=read.head=${FluentBitReadFromHead} --from-literal=read.tail=${FluentBitReadFromTail} --from-literal=logs.region=${RegionName} -n amazon-cloudwatch

kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml

kubectl get pods -n amazon-cloudwatch

# Installing Prometheus

kubectl create namespace prometheus

helm upgrade -i prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"

kubectl get pods -n prometheus