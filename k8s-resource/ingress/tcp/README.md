https://coderwall.com/p/wohavg/creating-a-simple-tcp-server-in-go
```
docker build . -t haoqing/tcp:latest
```
```
docker run -p 9123:9123 -it haoqing/tcp:latest sh
```
```
echo -n "test out the server" | nc localhost 3333
```

```
kubectl edit ds nginx-ingress-controller
```
```
        - containerPort: 9000
          hostPort: 9000
          name: tcp
          protocol: TCP
```
