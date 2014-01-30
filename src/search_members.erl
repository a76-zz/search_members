-module(search_members).

-export([start/0]).

start() ->
	ok = application:start(search_members).

