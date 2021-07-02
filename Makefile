VERSION=0.4

bash-boost-$(VERSION): src
	cp -r src $@
	cp LICENSE $@
	m4 -DM4_VERSION=$(VERSION) $@/bash-boost.sh.m4 > $@/bash-boost.sh
	$(RM) $@/bash-boost.sh.m4
	./flatten $@

release: bash-boost-$(VERSION).tar.gz

bash-boost-$(VERSION).tar.gz: bash-boost-$(VERSION)
	tar czvf $@ $<

clean:
	$(RM) -r bash-boost-$(VERSION)
	$(RM)    bash-boost-$(VERSION).tar.gz

test: bash-boost-$(VERSION)
	@./test
	@./test-portable

.PHONY: release clean test

