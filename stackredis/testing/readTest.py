#!/usr/bin/python3

import random, string, subprocess

for i in range(1000):
	request="http://127.0.0.1:38000/000000000000000000000000000000000000000000000"
	# print(request)
	subprocess.call(["curl", "-X", "GET", request], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
