COMPOSE_CMD=$(shell which podman-compose 2>/dev/null || which docker-compose)


demo: demo-down demo-up demo-product-create-and-report

demo-up:
	$(COMPOSE_CMD) -f docker/demo-compose.yaml up -d --force-recreate;

demo-down:
	$(COMPOSE_CMD) -f docker/demo-compose.yaml down

demo-product-create-and-report:
	sleep 10
	./scripts/create-product-report-results.sh demo