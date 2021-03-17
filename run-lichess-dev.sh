#!/bin/bash

cores="auto"

redis-server --daemonize yes
mongod --fork --logpath ~/mongod.log

cd /lichess/lila-ws
setsid nohup sbt run &

cd /lichess/fishnet
echo -e "[fishnet]\ncores=$cores\nuserbacklog=0\nsystembacklog=0\n" > fishnet.ini
nohup cargo run -- --endpoint "http://localhost:9665/fishnet/" &

cd /lichess/lila-fishnet
setsid nohup sbt run -Dhttp.port=9665 &

cd /lichess/lila
./lila run
