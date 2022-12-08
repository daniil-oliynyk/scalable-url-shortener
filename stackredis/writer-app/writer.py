import os
from redis.sentinel import Sentinel
from cassandra.cluster import Cluster
import time

sentinelHost = os.environ.get("SENTINEL_HOST", None)
sentinelPort = int(os.environ.get("SENTINEL_PORT", 26379))
redisMasterName = os.environ.get("REDIS_MASTER_NAME", 'mymaster')

def initMasterSlaves():
    if sentinelHost is not None and sentinelPort is not None:
        try:
            sentinel = Sentinel([(sentinelHost, sentinelPort)], socket_timeout=0.1)
            redis_master = sentinel.master_for(redisMasterName, decode_responses=True, socket_timeout=0.1)
            redis_slave = sentinel.slave_for(redisMasterName, decode_responses=True, socket_timeout=0.1)
            return [redis_master, redis_slave]
        except Exception as e:
            return sentinelHost+ " "+ str(sentinelPort) + 'Exception handled when started to perform actions: Details error {}\n'.format(e)
    else:
        return 'Environment variable sentinelHost or sentinelPort  is not found or empty. \n'


while True:
        time.sleep(5)

        #connect to cassandra
        cluster = Cluster(['10.11.1.99', '10.11.2.99', '10.11.3.99', '10.11.4.99', '10.11.1.100', '10.11.2.100', '10.11.3.100', '10.11.4.100'])
        session = cluster.connect('urls')

        #connect to redis
        r = initMasterSlaves()

        keys = []
        values = []
        for s in r[1].scan_iter():
                if not s.startswith('1_'):
                        keys.append(s)
                values.append(str(r[1].get(s)))

        #put all key and values in cassandra
        url_insert_stmt = session.prepare("INSERT INTO urlshorts (short, long) VALUES (?, ?)")
        for i in range(len(keys)):
                session.execute(url_insert_stmt, [keys[i], values[i]])

