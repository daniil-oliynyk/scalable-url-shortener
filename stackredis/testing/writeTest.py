#!/usr/bin/python3

import random, string, subprocess

for i in range(100):
	longResource = "http://"+''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(100))
	shortResource = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))

	request="http://127.0.0.1:38000/?short="+shortResource+"&long="+longResource
	#print(request)
	subprocess.call(["curl", "-X", "PUT", request], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
