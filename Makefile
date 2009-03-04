
.PHONY: test

all:
	$(MAKE) -C test
	$(MAKE) -C src

test.spec: test.spec.in
	cat test.spec.in | sed -e "s,@PATH@,$(PWD)," > $(PWD)/test.spec

test: test.spec src
	run_test -pa $PWD/test -spec test.spec -cover cover.spec
