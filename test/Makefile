
.PHONY: test clean

all:
	erl -make

test: all
	erl -s eunit test emock_stateless

clean:
	rm -f *.beam

