
SUB_DIRS = $(patsubst %/,%,$(dir $(wildcard */Makefile)))
SUB_MAKE = @$(MAKE) -C $* $(subst $*.,,$@)

.PHONY: compile
compile: $(addsuffix .compile,$(SUB_DIRS))

%.compile:
	$(SUB_MAKE)

.PHONY: test
test: $(addsuffix .test,$(SUB_DIRS))

%.test:
	$(SUB_MAKE)

.PHONY: clean
clean: $(addsuffix .clean,$(SUB_DIRS))

%.clean:
	$(SUB_MAKE)

