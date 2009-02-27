-module(emock).
-author(chsu79@gmail.com).

-export([gen_server/1, gen_server/2]).
-export([gen_fsm/1, gen_fsm/2]).

gen_server(Fun) when is_function(Fun, 2) ->
	spawn_link(fun () -> gen_server0(Fun) end).
gen_server(Fun, InitialState) when is_function(Fun, 3) ->
	spawn_link(fun () -> gen_server0(Fun, InitialState) end).

gen_server0(Fun) ->
	receive 
		{'$gen_call', {From, Ref}, Msg} ->
			case Fun(call, Msg) of
				{reply, Reply} ->
					From ! {Ref, Reply};
				no_reply ->
					ok
			end;
		{'$gen_cast', Msg} ->
			no_reply = Fun(cast, Msg);
		Msg ->
			no_reply = Fun(info, Msg)
	end,
	gen_server0(Fun).

gen_server0(Fun, State) ->
	receive 
		{'$gen_call', {From, Ref}, Msg} ->
			case Fun({call, State}, Msg) of
				{reply, Reply, NewState} ->
					From ! {Ref, Reply},
					gen_server0(Fun, NewState);
				{no_reply, NewState} ->
					gen_server0(Fun, NewState)
			end;
		{'$gen_cast', Msg} ->
			{no_reply, NewState} = Fun({cast, State}, Msg),
			gen_server0(Fun, NewState);
		Msg ->
			{no_reply, NewState} = Fun({info, State}, Msg),
			gen_server0(Fun, NewState)
	end.
			
gen_fsm(Fun) when is_function(Fun, 2) ->
	spawn_link(fun () -> gen_fsm0(Fun) end).
gen_fsm(Fun, InitialState) when is_function(Fun, 3) ->
	spawn_link(fun () -> gen_fsm0(Fun, InitialState) end).


gen_fsm0(Fun) ->
	receive
		{'$gen_event', Msg} ->
			no_reply = Fun(send_event, Msg);
		{'$gen_sync_event', {From, Ref}, Msg} ->
			case Fun(sync_send_event, Msg) of
				{reply, Reply} ->
					From ! {Ref, Reply};
				no_reply ->
					ok
			end;
		{'$gen_sync_all_state_event', {From, Ref}, Msg} ->
			case Fun(sync_send_all_state_event, Msg) of
				{reply, Reply} ->
					From ! {Ref, Reply};
				no_reply ->
					ok
			end;
		{'$gen_all_state_event', Msg} ->
			no_reply = Fun(send_all_state_event, Msg);
		Info ->
			no_reply = Fun(info, Info)
	end,
	gen_fsm0(Fun).

gen_fsm0(Fun, State) ->
	receive
		{'$gen_event', Msg} ->
			{no_reply, NewState} = Fun({send_event, State}, Msg),
			gen_fsm0(Fun, NewState);
		{'$gen_sync_event', {From, Ref}, Msg} ->
			case Fun({sync_send_event, State}, Msg) of
				{reply, Reply, NewState} ->
					From ! {Ref, Reply},
					gen_fsm0(Fun, NewState);
				{no_reply, NewState} ->
					gen_fsm0(Fun, NewState)
			end;
		{'$gen_sync_all_state_event', {From, Ref}, Msg} ->
			case Fun({sync_send_all_state_event, State}, Msg) of
				{reply, Reply, NewState} ->
					From ! {Ref, Reply},
					gen_fsm0(Fun, NewState);
				{no_reply, NewState} ->
					gen_fsm0(Fun, NewState)
			end;
		{'$gen_all_state_event', Msg} ->
			{no_reply, NewState} = Fun({send_all_state_event, State}, Msg),
			gen_fsm0(Fun, NewState);
		Info ->
			{no_reply, NewState} = Fun({info, State}, Info),
			gen_fsm0(Fun, NewState)
	end.
	
		

