.PHONY: test
test:
	$(CURDIR)/scripts/test-tx

.PHONY: prepare
prepare:
	$(CURDIR)/scripts/two-chainz \
	&& $(CURDIR)/scripts/handshake

.PHONY: clean
clean:
	rm -rf $(HOME)/.urelayer
