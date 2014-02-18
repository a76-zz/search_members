-module(search_members_db).

-behaviour(gen_server).

-export([start_link/0, members_search/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {riak_client}).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

members_search(Request) ->
    gen_server:call(?SERVER, {search, Request}).

init([]) ->
	{ok, RiakClient} = riakc_pb_socket:start_link("127.0.0.1", 8087),
	{ok, #state{riak_client = RiakClient}}.

terminate(_Reason, State) ->
	riakc_pb_socket:stop(State#state.riak_client).

handle_call({search, Request}, _From, State) ->
    Response = search(State#state.riak_client, Request),
    error_logger:info_msg("search response: ~p~n", [Response]),
    {reply, Response, State}.

search(Pid, Request) ->
    riakc_pb_socket:search(Pid, <<"members">>, Request).

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.






