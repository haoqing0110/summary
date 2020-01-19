package main

import (
	"log"
	"os"

	_ "haoqing.com/learn/c2/matchers"
	"haoqing.com/learn/c2/search"
)

func init() {
	log.SetOutput(os.Stdout)
}

func main() {
	search.Run("president")
}
