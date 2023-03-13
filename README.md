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

# Installing Grafana

mkdir grafana

cat << EoF > ./grafana/grafana.yaml
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.prometheus.svc.cluster.local
      access: proxy
      isDefault: true
EoF


kubectl create namespace grafana

helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values ./grafana/grafana.yaml \
    --set service.type=LoadBalancer
    
kubectl get all -n grafana
    
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://$ELB"

kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

Dashboards to import:
3119
6417