package main

import (
	"fmt"
	"github.com/yaml/yamlscript/go"
)

func main() {
	data, err := yamlscript.Load("a: [b, c]")

	if err != nil {
		return
	}

	fmt.Println(data)
}
