.PHONY: up
up:
	docker-compose up -d --build

.PHONY: down
down:
	docker-compose down --volumes --remove-orphans

.PHONY: clean
clean:
	rm -rf $(CURDIR)/fixtures/data

