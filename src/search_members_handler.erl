-module(search_members_handler).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {connection, server}).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
	{ok, Connection, Server} = amqp:start_rpc_server("localhost", <<"members_search_rpc">>, fun members_search/1),
	{ok, #state{connection = Connection, server = Server}}.

members_search(Request) ->
	search_members_db:members_search(Request).

terminate(_Reason, State) ->
	amqp:stop_rpc_server(State#state.connection, State#state.server).

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
