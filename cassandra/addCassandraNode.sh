#!/bin/bash
while (( "$#" )); do
	
	COMMAND="docker run --name cassandra-node -d -e CASSANDRA_BROADCAST_ADDRESS=$1 -p 7000:7000 -p 9042:9042 -e CASSANDRA_SEEDS= cassandra"

	shift

done

