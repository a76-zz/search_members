riak exception issue:

exception exit: undef
     in function  riak_pb_messages:msg_code/1
        called as riak_pb_messages:msg_code(rpbputreq)


solution:
rebuild reak_pb:
https://github.com/basho/riak-erlang-client/issues/151

to start:
erl -pa ebin deps/*/ebin deps/riakc/deps/riak_pb/ebin -s search_members

enable riak search in riak.conf:
search = on

list of riak buckets:
curl -i 'http://localhost:8098/riak?buckets=true'

create index:
according to the https://groups.google.com/forum/#!topic/nosql-databases/J7m3FSYM_RU

curl -i -XPUT http://localhost:8098/search/index/members -H 'content-type: application/json'

associate index to bucket:

curl -XPUT -H 'content-type: application/json' 'http://localhost:8098/buckets/members/props' -d '{"props":{"search_index":"members"}}' 

more details:
https://groups.google.com/forum/#!msg/nosql-databases/J7m3FSYM_RU/Hb1sWkMjj20J

put value:
curl -v -XPUT http://localhost:8098/buckets/members/keys/e911?returnbody=true -H "Content-Type: application/json" -d '{"first_name_s":"Ryan", "last_name_s":"Zezeski"}'

get all keys of the bucket:
curl -i 'http://localhost:8098/buckets/members/keys?keys=true'

get value by key:
curl -i 'http://localhost:8098/buckets/members/keys/e911'

search:
curl 'http://localhost:8098/solr/members/select?q=first_name_s:Ryan&wt=json'

tagging:
curl -v -XPUT http://localhost:8098/buckets/members/keys/e914?returnbody=true \
-H "Content-Type: application/json" \
-H "x-riak-meta-yz-tags:x-riak-meta-first_s, x-riak-meta-last_s" \
-H "x-riak-meta-first_s:Bill" \
-H "x-riak-meta-last_s:Evants" \
-d '{"first_name_s":"Bill", "last_name_s":"Evants"}'

It is required to use name value conventions according to the default schema https://github.com/basho/yokozuna/blob/develop/priv/default_schema.xml or other one related to the index.

If this rule is ignored then document content is not returned in the search result.
For example default schema defines postfix _s for string value.
If it is ommited in the document content and fields are defined without they will be not returned in the result search.
The same rule for tagging.

update sample:
update(Pid, Value) ->
    Get = riakc_pb_socket:get(Pid, <<"echo">>, <<"mine">>),
    case Get of 
        {ok, Object} ->
            Update = riakc_obj:update_value(Object, Value);
        {error, notfound} ->
            Update = riakc_obj:new(<<"echo">>, <<"mine">>, Value)
    end,
    riakc_pb_socket:put(Pid, Update).








