.PHONY: build generate

build:
	nix build .# .#mock

test:
	go test ./...

generate gen: gomod2nix.toml
	go run main.go

format fmt:
	nix fmt

gomod2nix.toml: go.mod go.sum flake.lock
	gomod2nix generate
