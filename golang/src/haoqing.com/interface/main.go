package main

import "fmt"

type animal interface {
	Speak()
}

type human struct {
	name string
	head string
	body string
	legs string
}

func (h *human) Speak() {
	fmt.Printf("I'm %v \n", h.name)
	fmt.Printf("my head is %v \n", h.head)
	fmt.Printf("my body is %v \n", h.body)
	fmt.Printf("my legs are %v \n", h.legs)
}

func main() {
	me := &human{
		"G",
		"big",
		"thin",
		"long",
	}
	me.Speak()
}
