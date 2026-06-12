PREFIX ?= /usr/local
BINDIR := $(DESTDIR)$(PREFIX)/bin

.PHONY: install uninstall test lint

install:
	install -d $(BINDIR)
	install -m 0755 puravida $(BINDIR)/puravida

uninstall:
	rm -f $(BINDIR)/puravida

test:
	bats test/

lint:
	shellcheck puravida
