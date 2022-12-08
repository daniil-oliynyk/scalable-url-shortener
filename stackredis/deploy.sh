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


echo "1- Start to push on remote registry the redis docker image which can be used as master or slave in the stack..."
cd /home/student/repo_a2group50/stackredis/agile-redis-master-slave 
docker build -f agile-redis-Dockerfile.yml -t agile-redis .
docker tag agile-redis $USERNAME/assignment:agile-redis 
docker push $USERNAME/assignment:agile-redis
echo "(1)End to build and push redis image to registry."
echo "-------------------------------------------------------\n"

echo "2- Start to push on remote registry the redis docker image which will be used to build sentinel..."
cd /home/student/repo_a2group50/stackredis/agile-redis-sentinel
docker build -f agile-redis-sentinel-Dockerfile.yml -t agile-redis-sentinel .
docker tag agile-redis-sentinel $USERNAME/assignment:agile-redis-sentinel
docker push $USERNAME/assignment:agile-redis-sentinel

echo "(2)End to build and push redis sentinel image to registry."
echo "-------------------------------------------------------\n"


echo "3- Start to push our python app  on the remote registry..."
cd /home/student/repo_a2group50/stackredis/python-app
docker build -f Dockerfile.yml -t agile-python-app .
docker tag agile-python-app $USERNAME/assignment:agile-python-app
docker push $USERNAME/assignment:agile-python-app
echo "(3)End to push our python app on the remote registry."
echo "-------------------------------------------------------\n"

echo "4- Start to push our python writer app  on the remote registry..."
cd /home/student/a2/repo_a2group50/stackredis/writer-app
docker build -f writerDockerfile.yml -t agile-writer-app .
docker tag agile-python-app $USERNAME/assignment:agile-writer-app
docker push $USERNAME/assignment:agile-writer-app
echo "(4)End to push our python app on the remote registry."
echo "-------------------------------------------------------\n"

cd /home/student/repo_a2group50/stackredis

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
