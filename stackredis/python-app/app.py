import os
from flask import Flask
from redis.sentinel import Sentinel
from flask import request
from flask import render_template
from flask import abort
from flask import redirect
from cassandra.cluster import Cluster
from werkzeug.exceptions import HTTPException
import validators

app = Flask(__name__)

sentinelHost = os.environ.get("SENTINEL_HOST", None)
sentinelPort = int(os.environ.get("SENTINEL_PORT", 26379))
redisMasterName = os.environ.get("REDIS_MASTER_NAME", 'mymaster')


def initMasterSlaves():
    if sentinelHost is not None and sentinelPort is not None:
        try:
            sentinel = Sentinel([(sentinelHost, sentinelPort)], socket_timeout=0.1)
            redis_master = sentinel.master_for(redisMasterName, socket_timeout=0.1)
            redis_slave = sentinel.slave_for(redisMasterName, socket_timeout=0.1)
            return [redis_master, redis_slave]
        except Exception as e:
            return sentinelHost+ " "+ str(sentinelPort) + 'Exception handled when started to perform actions: Details error {}\n'.format(e)
    else:
        return 'Environment variable sentinelHost or sentinelPort  is not found or empty. \n'

def connectCassCluster():
    try:
        cluster = Cluster(['10.11.1.100', '10.11.2.100', '10.11.3.100', '10.11.4.100', '10.11.1.99', '10.11.2.99', '10.11.3.99', '10.11.4.99'])
        session = cluster.connect('urls')
        return session
    except Exception as e:
        return "cannot connect to cassandra"

@app.errorhandler(404)
def page_not_found(e):
        return render_template('404.html'), 404

@app.route('/', methods=['PUT'])
def writeRedis():
	short = request.args.get('short')
	longURL = request.args.get('long')
	
	valid = validators.url(str(longURL))
	if valid==False:
		return "bad request\n", 400
		
	r = initMasterSlaves()
	r[0].set(str(short), str(longURL))
	return render_template('redirect_recorded.html'), 200

@app.route('/<shorted>', methods=['GET'])
def readRedis(shorted):
	try:
		r = initMasterSlaves()
		#if dosent exist, then check cassandra
		longUrl = None
		if not r[1].exists(str(shorted)):
			session = connectCassCluster()
			resp = session.execute("SELECT * FROM urlshorts WHERE short = %s", (str(shorted),))
			if len(resp.current_rows) is not 1:
				abort(404)
			longUrl = str(resp[0].long)
			#put into redis
			r[0].set(str(shorted), longUrl)
		else:
			longUrl = str(r[1].get(shorted))
		return redirect(longUrl, 307)
	except Exception as e:
		if isinstance(e, HTTPException):
			abort(e.code)
		else:
			return "bad request\n", 400		
		
if  __name__ == "__main__":
    app.run(host="0.0.0.0", port=611, debug=True)
