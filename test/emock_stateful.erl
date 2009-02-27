-module(emock_stateful).

-compile(export_all).

counter_server({call, Count}, {add, Add}) ->
	NewCount = Count + Add,
	{reply, NewCount, NewCount}.

test_code() ->
	Server = emock:gen_server(fun counter_server/2, 0),
	1 = gen_server:call(Server, {add, 1}),
	2 = gen_server:call(Server, {add, 1}),
	3 = gen_server:call(Server, {add, 1}),
	10 = gen_server:call(Server, {add, 7}),
	ok.

