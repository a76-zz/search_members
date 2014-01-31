enable riak search in riak.conf:
search = on

list of riak buckets:
curl -i 'http://localhost:8098/riak?buckets=true'

associate index to bucket:

curl -XPUT -H 'content-type: application/json' 'http://localhost:8098/buckets/members/props' -d '{"props":{"yz_index":"members"}}' 

more details:
https://groups.google.com/forum/#!msg/nosql-databases/J7m3FSYM_RU/Hb1sWkMjj20J

get all keys of the bucket:
curl -i 'http://localhost:8098/buckets/echo/keys?keys=true'

get value by key:
curl -i 'http://localhost:8098/riak/echo/mine'




