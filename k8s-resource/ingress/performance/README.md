https://www.nginx.com/blog/testing-the-performance-of-nginx-and-nginx-plus-web-servers/
https://www.nginx.com/blog/nginx-plus-sizing-guide-how-we-tested/

### Requests Per Second
```
for i in `seq 1 number-of-CPUs`; do
    taskset -c $i wrk -t 1 -c 50 -d 180s http://Reverse-Proxy-Server-IP-address/1kb.bin
done
```

### SSL/TLS Transactions Per Second
```
for i in `seq 1 number-of-CPUs`; do
    taskset -c $i wrk -t 1 -c 50 -d 180s -H 'Connection: close' https://Reverse-Proxy-Server-IP-address/0kb.bin
done
```
