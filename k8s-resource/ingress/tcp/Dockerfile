FROM golang:1.9.2

COPY main.go /go

RUN cd /go
RUN go build main.go
RUN mv main tcp

EXPOSE 9123
CMD [ "/go/tcp" ]
