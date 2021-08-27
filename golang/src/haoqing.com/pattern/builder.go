package pattern

import (
	"crypto/tls"
	"time"
)

type Server struct {
	Addr     string
	Port     int
	Protocol string
	Timeout  time.Duration
	MaxConns int
	TLS      *tls.Config
}

type ServerBuilder struct {
	Server
}

func (sb *ServerBuilder) Create(addr string, port int) *ServerBuilder {
	sb.Server.Addr = addr
	sb.Server.Port = port
	return sb
}

func (sb *ServerBuilder) WithProtocol(protocol string) *ServerBuilder {
	sb.Server.Protocol = protocol
	return sb
}

func (sb *ServerBuilder) WithMaxConn(maxconn int) *ServerBuilder {
	sb.Server.MaxConns = maxconn
	return sb
}

func (sb *ServerBuilder) WithTimeOut(timeout time.Duration) *ServerBuilder {
	sb.Server.Timeout = timeout
	return sb
}

func (sb *ServerBuilder) WithTLS(tls *tls.Config) *ServerBuilder {
	sb.Server.TLS = tls
	return sb
}

func (sb *ServerBuilder) Build() Server {
	return sb.Server
}

/*func main() {
	sb := ServerBuilder{}
	server := sb.Create("127.0.0.1", 8080).
		WithProtocol("udp").
		WithMaxConn(1024).
		WithTimeOut(30 * time.Second).
		Build()

	fmt.Printf("server %v", server)
}*/
