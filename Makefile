all: build

build: 
	./rebar3 compile
	./rebar3 release

run:
	./_build/default/rel/contacts/bin/contacts

test1:
	./rebar3 ct