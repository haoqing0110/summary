#!/bin/bash
for i in `seq 1 num_of_cpus`; do
    taskset -c $i wrk -t 1 -c 50 -d 180s -H 'Connection: close' https://test.ibm.com/s1-tls
done
