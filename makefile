create_cluster:
	@eksctl create cluster --name=eks-demo \
                      --region=us-east-1 \
                      --zones=us-east-1a,us-east-1b \
                      --without-nodegroup 


deploy_private_nodegroup: 
	@eksctl create nodegroup --cluster=eks-demo \
                        --region=us-east-1 \
                        --name=eks-demo-ng-private \
                        --node-type=t2.medium \
                        --nodes-min=2 \
                        --nodes-max=4 \
                        --node-volume-size=20 \
                        --ssh-access \
                        --ssh-public-key ~/.ssh/my-eks-key.pub \
                        --managed \
                        --asg-access \
                        --external-dns-access \
                        --full-ecr-access \
                        --appmesh-access \
                        --alb-ingress-access \
                        --node-private-networking 

create_oidc:
	@eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster eks-demo \
    --approve


create_lb_policy:
	@curl -o iam_policy_latest.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
	@aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy_latest.json > lb_policy_output.json

create_service_account:
	@eksctl create iamserviceaccount \
  --cluster=eks-demo \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=$$(cat lb_policy_output.json | jq -r '.Policy.Arn') \
  --override-existing-serviceaccounts \
  --approve

install_aws_loadbalancer:
	@helm repo add eks https://aws.github.io/eks-charts
	@helm repo update
	@helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-demo \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-0552d34775b7af753 \
  --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller

