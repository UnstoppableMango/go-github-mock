.PHONY: build test generate gen format fmt

build:
	nix build .# .#mock

test:
	go test ./...

generate gen: gomod2nix.toml
	nix run .

format fmt:
	nix fmt

gomod2nix.toml: go.mod go.sum flake.lock
	nix run .#gomod2nix -- generate
