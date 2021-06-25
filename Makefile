VERSION=0.2

bash-boost-$(VERSION): src
	cp -r src $@
	m4 -DM4_VERSION=$(VERSION) $@/bash-boost.sh.m4 > $@/bash-boost.sh
	$(RM) $@/bash-boost.sh.m4
	./flatten $@

clean:
	$(RM) -r bash-boost-$(VERSION)

