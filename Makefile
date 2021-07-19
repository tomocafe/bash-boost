VERSION=0.9

TARGET := bash-boost-$(VERSION)
SRCS := $(shell find src -type f -name "*.sh" | sort)

$(TARGET): doc $(SRCS) flatten
	$(RM) -r $@
	cp -r src $@
	cp LICENSE $@
	m4 -DM4_VERSION=$(VERSION) $@/bash-boost.sh.m4 > $@/bash-boost.sh
	$(RM) $@/bash-boost.sh.m4
	./flatten $@

release: bash-boost-$(VERSION).tar.gz

$(TARGET).tar.gz: $(TARGET)
	tar czvf $@ $<

clean:
	$(RM)    src/MANUAL.md
	$(RM) -r $(TARGET)
	$(RM)    $(TARGET).tar.gz

test: $(TARGET)/bash-boost.sh $(TARGET)/bash-boost-portable.sh
	@./test
	@./test-portable

src/MANUAL.md: $(SRCS) docgen
	$(RM) $@
	for f in $(SRCS); do ./docgen "$$f" >> $@; done

doc: src/MANUAL.md

.PHONY: release clean test doc

