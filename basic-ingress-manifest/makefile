deploy_ingress_class:
	@kubectl apply -f ingress-class.yaml

deploy_app:
	@kubectl apply -f app-deployment.yaml

deploy_ingres_rule:
	@kubectl apply -f ingres-rule.yaml


clanup_components:
	@kubectl delete -f ingress-class.yaml
	@kubectl delete -f app-deployment.yaml
	@kubectl delete -f ingres-rule.yaml