package main

import (
	"github.com/yaml/yamlscript/go"
	"fmt"
)

func main() {
    data, err := yamlscript.Load("a: [b, c]")

    if err != nil {
        return;
    }

    fmt.Println(data)
}
