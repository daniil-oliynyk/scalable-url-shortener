#!/bin/bash
echo "--------------------------------------------------------------------------------------------------------------"
echo "             REDIS STACK DEPLOYMENT                                                                           "
echo "--------------------------------------------------------------------------------------------------------------"

export SENTINEL_HOSTNAME=$1 #10.11.1.__
export REDIS_MASTER_HOSTNAME=$2 #10.11.1.__
export REDIS_SLAVE_NODE1_HOSTNAME=$3 #10.11.2.__
export REDIS_SLAVE_NODE2_HOSTNAME=$4 #10.11.3.__
export REDIS_SLAVE_NODE3_HOSTNAME=$5 #10.11.4.__
export USERNAME="therbajaj"

if [ -z $SENTINEL_HOSTNAME ] || [ -z $REDIS_MASTER_HOSTNAME ] || [ -z $REDIS_SLAVE_NODE1_HOSTNAME ]  || [ -z $REDIS_SLAVE_NODE2_HOSTNAME ] ||  [ -z $REDIS_SLAVE_NODE3_HOSTNAME ]  ; then
  echo "Status: Arguments missing. Cannot continue to build the stack. Missing SENTINEL_HOSTNAME, REDIS_MASTER_HOSTNAME, REDIS_SLAVE_NODE1_HOSTNAME, REDIS_SLAVE_NODE1_HOSTNAME" >&2
  exit 1;
fi

cd /home/student/a2/repo_a2group50/stackredis

sleep 3s

echo "4- Start to deploy the stack..."
export SENTINEL_IP=`docker node inspect --format {{.Status.Addr}} $SENTINEL_HOSTNAME`
export REDIS_MASTER_IP=`docker node inspect --format {{.Status.Addr}} $REDIS_MASTER_HOSTNAME`

echo "Sentinel hostname and IP: $SENTINEL_HOSTNAME -  $SENTINEL_IP"
echo "Redis Master hostname and IP: $REDIS_MASTER_HOSTNAME - $REDIS_MASTER_IP"
echo "Redis slave 1 hostname: $REDIS_SLAVE_NODE1_HOSTNAME"
echo "Redis slave 2 hostname: $REDIS_SLAVE_NODE2_HOSTNAME"
echo "Redis slave 3 hostname: $REDIS_SLAVE_NODE3_HOSTNAME"


docker stack deploy -c agile-redis-stack.yml stackredis
printf "(4)End to deploy the stack... Please wait until the services started\n\n\n"

sleep 3s

printf "Status: The stack deployment has been completed.\n\n"


docker service ls
printf "If all services replicas are not already deployed, please run << docker service ls >> to see if it now completed.\n"
