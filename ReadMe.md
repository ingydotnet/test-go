yamlscript-go-test-app
======================


## Synopsis

These should each be run separately (not as `make sysclean setup test`):

```
make sysclean
make setup
make test  # Currently fails to find 'go' after building all deps
make test  # Passes
```


## Description

This repo has a Makefile that does things with Go and YAMLScript (on the
`go-binding` branch)

The Makefile does not require a Go installation and ignores any you have.

All Go commands must be in the Makefile:

* `make go-get` - Works
* `make go-test` - Works but no `app_test.go` yet
* `make go-tidy` - Works
* `make go-build` - Works
* `make go-run` - Fails for not finding libyamlscript.so
