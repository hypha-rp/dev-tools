COMPOSE_CMD=$(shell which docker-compose 2>/dev/null || which podman-compose)


demo: demo-down demo-up demo-product-create-and-report

demo-up:
	$(COMPOSE_CMD) -f docker/demo-compose.yaml up -d --force-recreate;

demo-down:
	$(COMPOSE_CMD) -f docker/demo-compose.yaml down

demo-product-create-and-report:
	sleep 10
	./scripts/create-product-report-results.sh demo