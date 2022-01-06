VERSION=1.4

TARGET := bash-boost-$(VERSION)
SRCS := $(shell find src -type f -name "*.sh" | sort)

$(TARGET): check doc $(SRCS) flatten
	$(RM) -r $@
	cp -r src $@
	cp -r bin $@
	cp LICENSE $@
	m4 -DM4_VERSION=$(VERSION) $@/bash-boost.sh.m4 > $@/bash-boost.sh
	$(RM) $@/bash-boost.sh.m4
	./flatten $@
	$(RM) ./latest
	ln -s $(TARGET) latest

release: $(TARGET).tar.gz

$(TARGET).tar.gz: $(TARGET)
	tar czvf $@ $<

clean:
	$(RM)    src/MANUAL.md
	$(RM) -r $(TARGET)
	$(RM)    $(TARGET).tar.gz
	$(RM)    latest

test: $(TARGET)/bash-boost.sh $(TARGET)/bash-boost-portable.sh
	@./test
	@./test-portable

src/MANUAL.md: $(SRCS) docgen
	$(RM) $@
	./docgen --title $(VERSION) > $@
	for f in $(SRCS); do ./docgen "$$f" >> $@; done

src/man/man1/bash-boost.1: src/MANUAL.md
	$(RM) $@
	mkdir -p src/man/man1
	pandoc -s src/MANUAL.md -t man -o $@

doc: src/MANUAL.md src/man/man1/bash-boost.1

check: $(SRCS)
	@./check $(SRCS)

.PHONY: release clean test doc check

