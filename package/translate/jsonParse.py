import json
import sys

f = open(sys.argv[1],)
values = json.load(f)
keys = sys.argv[2].split(".")
first = True
try:
    for key in keys:
        if first:
            first = False
            curValue = values[key]
        else:
            curValue = curValue[key]
    print(curValue)
except:
    raise SystemExit('Error: Invalid Key or File')
