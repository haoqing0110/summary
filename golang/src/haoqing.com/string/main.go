package main

import "fmt"

type info struct {
    name string
    id int
    ext string
}

func main()  {
    v := info{"Nan", 33, ""}
    fmt.Printf("%v\n", v)
    fmt.Printf("%+v\n", v)
    fmt.Printf("%#v\n", v)
}
