#!/usr/bin/env python
import statistics 
lenfile = open('variant_read_length.txt','r').readlines()
positionfile = open('variant_pos.txt','r').readlines()
distance = []
for i in range(len(lenfile)):
    lenfile[i]=int(lenfile[i])
    positionfile[i]=int(positionfile[i])
    half= lenfile[i]/2
    if positionfile[i] > half:
        dis=lenfile[i]-positionfile[i]
    else:
        dis=positionfile[i]
    distance.append(dis)

print(statistics.stdev (distance))
