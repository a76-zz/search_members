-module(search_members_server).

-behaviour(gen_sever).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-record(state, {amqp_server, riak_client}).

-include_lib("deps/amqp_client/include/amqp_client.hrl").

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

members_search(Request) ->
    gen_server:call(?MODULE, {search, Request}).

init([]) ->
    Channel = <<"rpc">>,
    {ok, RiakClient} = riakc_pb_socket:start_link("127.0.0.1", 8087),
    {ok, Connection} = amqp_connection:start(#amqp_params_network{host = "localhost"}),
    AmqpServer = amqp_rpc_server:start(Connection, Channel, fun members_search/1),
    
    io:format("Listening ~p channel.", [Channel]),
    {ok, #state{amqp_server = AmqpServer, riak_client = RiakClient}}.

terminate(_Reason, #state{amqp_server = AmqpServer, riak_client = RiakClient}) ->
    riakc_pb_socket:stop(RiakClient),
    amqp_rpc_server:stop(AmqpServer),
    ok.

handle_call({search, Request}, _From, State) ->
    Pid = State#state.riak_client,
    Get = riakc_pb_socket:get(Pid, <<"echo">>, <<"mine">>),
    case Get of 
        {ok, Object} ->
            Update = riakc_obj:update_value(Object, Request);
        {error, notfound} ->
            Update = riakc_obj:new(<<"echo">>, <<"mine">>, Request)
    end,
    riakc_pb_socket:put(Pid, Update),
    {reply, Request, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.









