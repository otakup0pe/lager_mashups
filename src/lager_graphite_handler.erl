-module(lager_graphite_handler).
-behaviour(gen_event).

-export([
    init/1,
    handle_event/2,
    handle_call/2,
    handle_info/2,
    code_change/3,
    terminate/2
]).

-include("lager_mashups.hrl").
-record(state, {graphite, error_key, warning_key, error_count=0, warning_count=0, last}).

enow() ->
    calendar:datetime_to_gregorian_seconds(calendar:universal_time()).
init([Graphite, ErrorKey, WarningKey]) -> 
    {ok, #state{graphite = Graphite, error_key=ErrorKey, warning_key=WarningKey, last = enow()}}.

handle_call(_, State) ->
	{ok, ok, State}.

handle_info(_, State) ->
	{ok, State}.

handle_event({log, Message}, #state{error_count = EC, warning_count = WC} = State) ->
    {ok, p_sink(case lager_msg:severity_as_int(Message) of
		    ?WARNING ->
			State#state{warning_count = WC + 1};
		    ?ERROR ->
			State#state{error_count = EC + 1};
		    _ ->
			State
		end)};
handle_event(_, State) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

p_sink(State) ->
    p_sink(enow(), State).
p_sink(Now, #state{graphite = G, error_key = EK, warning_key = WK, error_count = EC, warning_count = WC, last = L} = State) when Now - L > 60 ->
    graphite:send(G, [{EK, EC}, {WK, WC}]),
    State#state{error_count = 0, warning_count = 0, last = Now};
p_sink(_, State) ->
    State.
