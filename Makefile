.PHONY: build generate

build:
	nix build .#

generate:
	go run main.go
	gomod2nix generate

gomod2nix.toml: go.mod go.sum flake.lock
	gomod2nix generate
