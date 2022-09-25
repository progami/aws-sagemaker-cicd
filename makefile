terraform-plan:
	cd infra && terraform plan

terraform-apply:
	cd infra && terraform apply -auto-approve

terraform-destroy:
	cd infra && terraform destroy -auto-approve