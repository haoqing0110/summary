//https://colobu.com/2015/10/09/Linux-Signals/
package main

import "fmt"
import "os"
import "os/signal"
import "syscall"

func main() {
  sigs := make(chan os.Signal, 1)
  done := make(chan bool, 1)

  signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

  go func() {
    sig := <- sigs
    fmt.Println()
    fmt.Println(sig)
    done <- true
  }()

  fmt.Println("awating signals")
  <-done
  fmt.Println("existing")
}
