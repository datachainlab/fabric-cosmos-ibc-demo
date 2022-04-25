.PHONY: up
up:
	docker-compose -f ../docker-compose.yaml \
		up -d --build cosmosnode

.PHONY: down
down:
	docker-compose -f ../docker-compose.yaml \
		rm -fsv cosmosnode

.PHONY: clean
clean:
	rm -rf $(CURDIR)/fixtures/data

