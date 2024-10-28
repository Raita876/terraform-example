.PHONY: plan
plan:
	source .env && ./main.sh plan

.PHONY: apply
apply:
	source .env && ./main.sh apply

.PHONY: destroy
destroy:
	source .env && ./main.sh destroy
