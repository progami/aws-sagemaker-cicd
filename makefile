terraform-plan:
	cd infra && terraform plan

terraform-apply:
	cd infra/src && zip lambda_get lambda_get.py && zip lambda_push lambda_push.py && cd ../ && terraform apply -auto-approve

terraform-destroy:

	cd infra && terraform destroy -auto-approve