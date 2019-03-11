package main

import "fmt"

var str1 = "this is string 1"
var str2 = "this is string 1"

func main() {
    if str1 == str2 {
	fmt.Println(str1)
	fmt.Println(str2)
    }
}
