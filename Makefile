SHELL := bash

ROOT := $(shell pwd)

YS_REPO_CLONE := /tmp/yamlscript-repo
YS_REPO_URL := https://github.com/yaml/yamlscript
YS_REPO_BRANCH := go-binding
YS_INSTALL_PREFIX := /tmp/ys-local
YS_INSTALLED := $(YS_INSTALL_PREFIX)/lib/libyamlscript.so

GO_DEPS := go-deps

unexport GOROOT GOBIN GOPATH
GOROOT :=
GOBIN :=
GOPATH :=

ifneq (,$(wildcard $(YS_REPO_CLONE)))
  export GOROOT := $(shell $(MAKE) --no-print-directory -C $(YS_REPO_CLONE)/go print-goroot)
  export GOBIN := $(GOROOT)/bin
  export GOPATH := /tmp/yamlscript
  export PATH := $(GOBIN):$(PATH)
  export LD_LIBRARY_PATH := $(LD_LIBRARY_PATH):/tmp/yamlscript-repo/libyamlscript/lib
  GO_PSEUDO_VERSION := $(shell $(MAKE) --no-print-directory -C $(YS_REPO_CLONE)/go pseudo-version)
endif

export CGO_CFLAGS := -I $(YS_INSTALL_PREFIX)/include
export CGO_LDFLAGS := -L $(YS_INSTALL_PREFIX)/lib


default:

vars:
	@echo GOROOT=$(GOROOT)
	@echo GOPATH=$(GOPATH)
	@echo GOBIN=$(GOBIN)
	@echo GO_PSEUDO_VERSION=$(GO_PSEUDO_VERSION)
	@echo
	@echo PATH=$(PATH)

setup: $(YS_REPO_CLONE)

test: check-setup $(YS_INSTALLED) go-mod go-get go-test go-tidy go-mod-reset

go-mod: go.mod
	@echo === $@
	git checkout -- $<
	perl -pi -e "s/v0.*/$(GO_PSEUDO_VERSION)/" $<

go-get:
	@echo === $@
	go get github.com/yaml/yamlscript/go@$(GO_PSEUDO_VERSION)

go-test:
	@echo === $@
	go test

go-tidy:
	@echo === $@
	go mod tidy

go-mod-reset: go.mod
	@echo === $@
	git checkout -- $<

go-build: go-mod go-get
	go build -o app app.go

go-run: go-mod go-get
	go run app.go

check-setup:
	@echo === $@
ifndef GO_PSEUDO_VERSION
	$(error Run: make setup)
endif

clean:
	[[ ! -d $(GO_DEPS) ]] || chmod -R u+w $(GO_DEPS)
	[[ ! -d go-path ]] || chmod -R u+w go-path
	$(RM) -r $(GO_DEPS) go-path
	$(RM) app

sysclean: clean
	$(RM) -r $(YS_REPO_CLONE) $(GOROOT) $(YS_INSTALL_PREFIX)

$(YS_REPO_CLONE):
	git clone --branch=$(YS_REPO_BRANCH) $(YS_REPO_URL) $@

$(YS_INSTALLED): $(YS_REPO_CLONE)
	$(MAKE) -C $</libyamlscript install PREFIX=$(YS_INSTALL_PREFIX)
