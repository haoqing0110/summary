package main

import (
	"github.com/reiver/go-telnet"
)

func main() {
	var caller telnet.Caller = telnet.StandardCaller

	//@TOOD: replace "example.net:23" with address you want to connect to.
	telnet.DialToAndCall("9.111.255.158:23", caller)

}
