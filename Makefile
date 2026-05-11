.PHONY: build generate gen format fmt test tidy

build:
	nix build .# .#mock

test:
	go test ./...

tidy: go.sum gomod2nix.toml

generate gen: gomod2nix.toml .github_openapi_version
	nix run .

format fmt:
	nix fmt

# Not a true dependency on go.sum, but a convenient trigger for re-checking the tag
.github_openapi_version: go.sum
	gh release view --repo github/rest-api-description --json tagName --jq .tagName > .github_openapi_version

go.sum: go.mod $(shell find . -name '*.go')
	go mod tidy

gomod2nix.toml: go.mod go.sum flake.lock
	nix run .#gomod2nix -- generate
