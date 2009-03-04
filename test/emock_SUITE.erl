-module(emock_SUITE).
-compile(export_all).

all() ->
    [
     stateful_server,
     stateless_server,
     stateless_server_noreply,
     unittest
    ].


unittest(_) ->
    %% nop
    ok.

stateless_server(_) ->
    Fun = 
	fun 
	    (call, X) ->
		{reply, X};
	    (cast, cast) ->
		no_reply;
	    (info, info) ->
		no_reply
	end,
    
    Mock = emock:gen_server(Fun),
    link(Mock),
    
    test1 = gen_server:call(Mock, test1),
    ok = gen_server:cast(Mock, cast),
    Mock ! info,
    test2 = gen_server:call(Mock, test2),
    ok = gen_server:cast(Mock, cast),
    Mock ! info,
    test3 = gen_server:call(Mock, test3),
    ok = gen_server:cast(Mock, cast),
    Mock ! info,
    
    erlang:exit(Mock, normal),
    ok.

stateless_server_noreply(_) ->
    Fun = 
	fun 
	    (call, _) ->
		no_reply
	end,
    
    Mock = emock:gen_server(Fun),
    
    {'EXIT', {timeout, _}} = (catch gen_server:call(Mock, whatever, 100)),
    
    ok.

stateful_server(_) ->
    Fun = 
	fun ({call, Acc}, {add, Item}) ->
		{reply, ok, [Item|Acc]};
	    ({call, Acc}, drain) ->
		{reply, Acc, []}
	end,
    
    Mock = emock:gen_server(Fun, []),
    
    ok = gen_server:call(Mock, {add, a}),
    ok = gen_server:call(Mock, {add, b}),
    ok = gen_server:call(Mock, {add, c}),
    
    [c,b,a] = gen_server:call(Mock, drain),
    
    ok.

    
