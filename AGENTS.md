# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build and test
go build ./...
go test ./...

# Run a single test
go test ./src/mock/... -run TestName

# Regenerate endpointpattern.go from GitHub's OpenAPI specs
go run main.go

# Format code
gofmt -w .

# Nix build
nix build .#

# Update gomod2nix.toml after go.mod changes
gomod2nix generate
```

## Architecture

This is a Go library (`github.com/unstoppablemango/go-github-mock`) for mocking GitHub API calls in unit tests. Users import it to create a mocked `*http.Client` that can be passed to `github.NewClient()`.

### Code Generation

`src/mock/endpointpattern.go` is **generated** — do not edit it directly. It contains hundreds of `EndpointPattern` variables (e.g. `GetUsersByUsername`, `PostReposIssuesByOwnerByRepo`) auto-generated from GitHub's OpenAPI specs.

- `main.go`: Entry point for the generator. Fetches GitHub's OpenAPI JSON specs (both standard and enterprise), parses endpoint paths/methods, and writes `endpointpattern.go`. Also handles updating the `go-github` dependency version.
- `src/gen/gen.go`: Core generation logic — fetches OpenAPI specs, converts URL patterns to Go variable names (e.g. `/repos/{owner}/{repo}` → `GetReposByOwnerByRepo`).
- `src/gen/gen_mutations.go`: Handles edge cases where the gorilla/mux routing pattern must differ from the raw OpenAPI spec (e.g. making `{path}` optional for `/repos/{owner}/{repo}/contents/{path}`).
- `hack/gen.sh`: Automation script that runs the generator on `master` branch, commits, and pushes.

### Mock Package (`src/mock/`)

The public API consumers use:

- `server.go`: `NewMockedHTTPClient` and `NewMockedHTTPClientAndServer` — create a `*httptest.Server` with a gorilla/mux router, wrapped in an `EnforceHostRoundTripper` that redirects all requests to the test server. `FIFOResponseHandler` serves pre-recorded responses in order (panics when exhausted). `PaginatedResponseHandler` handles pagination via `Link` headers.
- `server_options.go`: `MockBackendOption` functions — `WithRequestMatch` (FIFO responses), `WithRequestMatchHandler` (custom handler), `WithRequestMatchPages` (pagination), enterprise variants, and `WithRateLimit`.
- `utils.go`: `MustMarshal` (JSON marshal or panic) and `WriteError` (write a `github.ErrorResponse`).
- `endpointpattern.go`: Generated file with all endpoint constants.

### Key Design Pattern

Options are `func(*mux.Router)` closures (`MockBackendOption`). Each call to `WithRequestMatch*` registers a route handler on the mux router. The mocked HTTP client routes all requests to the test server regardless of hostname.

### Nix Integration

The project uses Nix flakes with `gomod2nix` for reproducible builds. When `go.mod` changes, run `gomod2nix generate` to keep `gomod2nix.toml` in sync (CI enforces this).
