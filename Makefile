MAJOR_VERSION=1
VERSION=1.11

TARGET := bash-boost-$(VERSION)
SRCS := $(shell find src -type f -name "*.sh" | sort)

full: $(TARGET) check doc

only: $(TARGET)

$(TARGET): $(SRCS) flatten src/bash-boost.sh.m4
	$(RM) -r $@
	cp -r src $@
	cp -r bin $@
	cp LICENSE $@
	m4 -DM4_VERSION=$(VERSION) $@/bash-boost.sh.m4 > $@/bash-boost.sh
	$(RM) $@/bash-boost.sh.m4
	./flatten $@
	$(RM) ./latest
	ln -s $(TARGET) latest
	$(RM) ./bash-boost-$(MAJOR_VERSION).latest
	ln -s $(TARGET) ./bash-boost-$(MAJOR_VERSION).latest

release: $(TARGET).tar.gz

$(TARGET).tar.gz: $(TARGET)
	tar czvf $@ $<

clean:
	$(RM)    src/MANUAL.md
	$(RM) -r $(TARGET)
	$(RM)    $(TARGET).tar.gz
	$(RM)    latest
	$(RM)    bash-boost-$(MAJOR_VERSION).latest

test: $(TARGET) check
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

.PHONY: full only release clean test doc check

