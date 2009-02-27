-module(emock_stateless).

-compile(export_all).

code_under_test(Server, X) ->
	%% horribly complex code here,
	Reply = gen_server:call(Server, X),
	%% more horribly complex code here
	Reply.

echo_server(call, X) ->
	{reply, X}.

test_code() ->
	42 = code_under_test(emock:gen_server(fun echo_server/2), 42).

