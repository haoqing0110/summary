package pattern

import (
	"crypto/tls"
	"time"
)

type Option func(s *Server)

func Protocol(p string) Option {
	return func(s *Server) {
		s.Protocol = p
	}
}

func Timeout(t time.Duration) Option {
	return func(s *Server) {
		s.Timeout = t
	}
}

// 当我们调用其中的一个函数用 MaxConns(30) 时
// 其返回值是一个 func(s* Server) { s.MaxConns = 30 } 的函数。
// 这个叫高阶函数。
func MaxConns(maxconns int) Option {
	return func(s *Server) {
		s.MaxConns = maxconns
	}
}
func TLS(tls *tls.Config) Option {
	return func(s *Server) {
		s.TLS = tls
	}
}

func NewServer(addr string, port int, options ...func(*Server)) (*Server, error) {

	srv := Server{
		Addr:     addr,
		Port:     port,
		Protocol: "tcp",
		Timeout:  30 * time.Second,
		MaxConns: 1000,
		TLS:      nil,
	}
	for _, option := range options {
		option(&srv)
	}
	//...
	return &srv, nil
}

// 不但解决了使用 Config 对象方式 的需要有一个config参数，但在不需要的时候，是放 nil 还是放 Config{}的选择困难,
// 也不需要引用一个Builder的控制对象，直接使用函数式编程的试，在代码阅读上也很优雅。
/*func main() {
	s1, _ := NewServer("localhost", 1024)
	s2, _ := NewServer("localhost", 2048, Protocol("udp"))
	s3, _ := NewServer("0.0.0.0", 8080, Timeout(300*time.Second), MaxConns(1000))
}*/
