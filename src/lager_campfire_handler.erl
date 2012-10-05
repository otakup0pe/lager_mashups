-module(lager_campfire_handler).

-behaviour(gen_event).
-export([init/1, handle_event/2, handle_info/2, handle_call/2, terminate/2, code_change/3]).

-include("lager_mashups.hrl").

-record(state, {erlfire, room, level, formatter, format_config}).

-define(CAMPFIRE_FORMAT,[time, " [", severity,"] ", message]).

init([N, Level, RoomID]) ->
    init([N, Level, RoomID, {lager_default_formatter, ?CAMPFIRE_FORMAT}]);
init([N, Level, RoomID, {Formatter, FConfig}]) ->
    {ok, #state{level = lager_util:level_to_num(Level), room=RoomID, erlfire=N, formatter = Formatter, format_config = FConfig}}.

handle_info(_, State) ->
    {ok, State}.

handle_call(get_loglevel, #state{level = Level} = State) ->
    {ok, Level, State};
handle_call({set_loglevel, Level}, State) ->
    case lists:member(Level, ?LEVELS) of
	true ->
	    {ok, ok, State#state{level=lager_util:level_to_num(Level)}}
    end.

%% @doc Replacing this module with newer version
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> ok.

handle_event({log, Message}, #state{level=L, formatter=F, format_config=FC} = State) ->
    case lager_util:is_loggable(Message, L, ?MODULE) of
	true ->
	    ok = p_emit(F:format(Message, FC), State);
	false ->
	    ok
    end,
    {ok, State};
handle_event(_, State) ->
    {ok, State}.

p_emit(Message, #state{erlfire=N, room=R}) ->
    ok = erlfire:chat(N, R, Message).
