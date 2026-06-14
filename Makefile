PREFIX ?= /usr/local
BINDIR := $(DESTDIR)$(PREFIX)/bin
MANPREFIX ?= $(PREFIX)/share/man
MANDIR := $(DESTDIR)$(MANPREFIX)/man1

.PHONY: install uninstall install-pv uninstall-pv test lint

install:
	install -d $(BINDIR)
	install -m 0755 puravida $(BINDIR)/puravida
	install -d $(MANDIR)
	install -m 0644 man/puravida.1 $(MANDIR)/puravida.1

uninstall:
	rm -f $(BINDIR)/puravida
	rm -f $(MANDIR)/puravida.1

# Opt-in `pv` shortcut. Shadows the `pv` (pipe viewer) utility if installed.
install-pv: install
	ln -sf puravida $(BINDIR)/pv

uninstall-pv:
	rm -f $(BINDIR)/pv

test:
	bats test/

lint:
	shellcheck puravida
