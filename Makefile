VERSION=0.6

SRCS := $(shell find src -type f)

bash-boost-$(VERSION): doc $(SRCS) flatten
	$(RM) -r $@
	cp -r src $@
	cp LICENSE $@
	m4 -DM4_VERSION=$(VERSION) $@/bash-boost.sh.m4 > $@/bash-boost.sh
	$(RM) $@/bash-boost.sh.m4
	./flatten $@

release: bash-boost-$(VERSION).tar.gz

bash-boost-$(VERSION).tar.gz: bash-boost-$(VERSION)
	tar czvf $@ $<

clean:
	$(RM)    src/MANUAL.md
	$(RM) -r bash-boost-$(VERSION)
	$(RM)    bash-boost-$(VERSION).tar.gz

test: bash-boost-$(VERSION)
	@./test
	@./test-portable

src/MANUAL.md: $(SRCS) docgen
	$(RM) $@
	for f in $(SRCS); do ./docgen "$$f" >> $@; done

doc: src/MANUAL.md

.PHONY: release clean test doc

