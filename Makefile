.PHONY: build test generate gen update-openapi format fmt

build:
	nix build .# .#mock

test:
	go test ./...

generate gen: gomod2nix.toml .github_openapi_version
	nix run .

.github_openapi_version:
	gh release view --repo github/rest-api-description --json tagName --jq .tagName > .github_openapi_version

format fmt:
	nix fmt

gomod2nix.toml: go.mod go.sum flake.lock
	nix run .#gomod2nix -- generate
