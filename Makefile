SHELL := bash

ROOT := $(shell pwd)

YS_VERSION := v0.1.65

YS_GO_PATH := /tmp/go-path
YS_REPO_CLONE := /tmp/yamlscript-repo
YS_REPO_URL := https://github.com/yaml/yamlscript
YS_REPO_BRANCH := main
YS_INSTALL_PREFIX := /tmp/ys-local
YS_INSTALL_LIB := $(YS_INSTALL_PREFIX)/lib
YS_INSTALLED := $(YS_INSTALL_LIB)/libyamlscript.so

GO_DEPS := go-deps

unexport GOROOT GOBIN GOPATH
GOROOT :=
GOBIN :=
GOPATH :=

ifneq (,$(wildcard $(YS_REPO_CLONE)))
  export GOROOT := $(shell $(MAKE) --no-print-directory -C $(YS_REPO_CLONE)/go print-goroot | tail -n1)
  export GOBIN := $(GOROOT)/bin
  export GOPATH := $(YS_GO_PATH)
  export PATH := $(GOBIN):$(PATH)
  export LD_LIBRARY_PATH := $(YS_INSTALL_LIB):$(LD_LIBRARY_PATH)
endif

export CGO_CFLAGS := -I $(YS_INSTALL_PREFIX)/include
export CGO_LDFLAGS := -L $(YS_INSTALL_PREFIX)/lib


default:

vars:
	@echo GOROOT=$(GOROOT)
	@echo GOPATH=$(GOPATH)
	@echo GOBIN=$(GOBIN)
	@echo
	@echo PATH=$(PATH)

setup: $(YS_REPO_CLONE)

test: check-setup $(YS_INSTALLED) go-get go-test go-build go-run go-tidy

go-get:
	@echo === $@
	go get github.com/yaml/yamlscript-go@$(YS_VERSION)

go-test:
	@echo === $@
	go test

go-tidy:
	@echo === $@
	go mod tidy

go-build: go-get
	@echo === $@
	go build -o app app.go

go-run: go-get $(YS_INSTALLED)
	@echo === $@
	go run app.go

check-setup:
	@echo === $@
ifeq (,$(GOPATH))
	$(error Run: make setup)
endif

clean:
	[[ ! -d $(GO_DEPS) ]] || chmod -R u+w $(GO_DEPS)
	[[ ! -d $(YS_GO_PATH) ]] || chmod -R u+w $(YS_GO_PATH)
	$(RM) -r $(GO_DEPS) $(YS_GO_PATH)
	$(RM) app

sysclean: clean
	$(RM) -r $(YS_REPO_CLONE) $(GOROOT) $(YS_INSTALL_PREFIX)

$(YS_REPO_CLONE):
	git clone --branch=$(YS_REPO_BRANCH) $(YS_REPO_URL) $@

$(YS_INSTALLED): $(YS_REPO_CLONE)
	$(MAKE) -C $</libyamlscript install PREFIX=$(YS_INSTALL_PREFIX)
