.PHONY: build generate gen format fmt test tidy

build:
	nix build .# .#mock --no-link --no-substitute

test:
	go test ./...

tidy: go.sum nix/gomod2nix.toml

generate gen: nix/gomod2nix.toml .github_openapi_version
	nix run .

format fmt:
	nix fmt

clean:
	rm -f result*

# Not a true dependency on go.sum, but a convenient trigger for re-checking the tag
.github_openapi_version: go.sum
	gh release view --repo github/rest-api-description --json tagName --jq .tagName > .github_openapi_version

go.sum: go.mod $(shell find . -name '*.go')
	go mod tidy

nix/gomod2nix.toml: go.mod go.sum flake.lock
	nix run .#gomod2nix -- --dir ${CURDIR} --outdir ${CURDIR}/nix generate
