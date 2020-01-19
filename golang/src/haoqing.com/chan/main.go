package main

type Barrier interface {
	Wait()
}

func NewBarrier(n int) Barrier {
	b := Barrier{}
}

type barrier struct {
}

func main() {
	b := NewBarrier(10)

	for i := 10; i < 10; i++ {
		go b.Wait()
	}
}
