-module(emock_stateless).
-compile(export_all).

-include_lib("eunit/include/eunit.hrl").

echo_server(call, X) ->
	erlang:display(X),
	{reply, X}.

echo_server_test_() ->
	{setup,
		fun () -> emock:gen_server(fun echo_server/2) end,
		fun(Server) -> exit(Server, normal) end,
		fun(Server) -> [
			?_assertEqual(42, gen_server:call(Server, 42)),
			?_assertEqual(foo, gen_server:call(Server, foo))
			]
		end
		}.


