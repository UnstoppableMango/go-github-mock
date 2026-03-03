package gen

import (
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"regexp"
	"strings"

	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

const GITHUB_OPENAPI_VERSION_FILE = ".github_openapi_version"

const OUTPUT_FILE_HEADER = `package mock

// Code generated; DO NOT EDIT.

`
const OUTPUT_FILEPATH = "src/mock/endpointpattern.go"

// Replacing deprecated method strings.Title
// requires a "Caser"
var Title = cases.Title(language.English)

var (
	// paramRe matches path parameter placeholders like {owner}, {enterprise-team}
	paramRe = regexp.MustCompile(`\{[^}]+\}`)
	// tokenRe matches valid Go identifier characters and path separators
	tokenRe = regexp.MustCompile(`[a-zA-Z0-9\/\{\}\_]+`)
)

// ReadOpenAPIVersion reads the pinned OpenAPI spec version from GITHUB_OPENAPI_VERSION_FILE.
func ReadOpenAPIVersion() (string, error) {
	b, err := os.ReadFile(GITHUB_OPENAPI_VERSION_FILE)
	if err != nil {
		return "", fmt.Errorf("error reading %s: %w", GITHUB_OPENAPI_VERSION_FILE, err)
	}
	return strings.TrimSpace(string(b)), nil
}

// OpenAPIURLs returns the standard and enterprise OpenAPI spec URLs for the given version tag.
func OpenAPIURLs(version string) (standard, enterprise string) {
	base := "https://raw.githubusercontent.com/github/rest-api-description/" + version
	standard = base + "/descriptions/api.github.com/api.github.com.json"
	enterprise = base + "/descriptions/ghec/ghec.json"
	return
}

type ScrapeResult struct {
	HTTPMethod      string
	EndpointPattern string
}

func FetchAPIDefinition(d string) []byte {
	resp, err := http.Get(d)

	if err != nil {
		slog.Info(
			"error fetching github's api definition",
			"err", err.Error(),
		)

		os.Exit(1)
	}

	defer resp.Body.Close()

	bodyBytes, err := io.ReadAll(resp.Body)

	if err != nil {
		slog.Info(
			"error fetching github's api definition",
			"err", err.Error(),
		)

		os.Exit(1)
	}

	return bodyBytes
}

// FormatToGolangVarName generated the proper golang variable name
// given a endpoint format from the API
func FormatToGolangVarName(sr ScrapeResult) string {
	result := Title.String(strings.ToLower(sr.HTTPMethod))

	if sr.EndpointPattern == "/" {
		return result + "Slash"
	}

	// Replace hyphens inside path params with underscores to preserve them as single tokens
	// e.g. {enterprise-team} -> {enterprise_team}, preventing {enterprise/team} split
	pattern := paramRe.ReplaceAllStringFunc(sr.EndpointPattern, func(m string) string {
		return strings.ReplaceAll(m, "-", "_")
	})

	// handles urls with dashes in them (outside path params)
	pattern = strings.ReplaceAll(pattern, "-", "/")

	// cleans up varname when pattern was mutated
	// e.g see `GetReposContentsByOwnerByRepoByPath`
	matches := tokenRe.FindAllString(pattern, -1)
	pattern = strings.Join(matches, "")

	epSplit := strings.Split(
		pattern,
		"/",
	)

	// handle the first part of the variable name
	for _, part := range epSplit {
		if len(part) < 1 || string(part[0]) == "{" {
			continue
		}

		splitPart := strings.Split(part, "_")

		for _, p := range splitPart {
			result = result + Title.String(p)
		}
	}

	//handle the "By`X`" part of the variable name
	for _, part := range epSplit {
		if len(part) < 1 {
			continue
		}

		if string(part[0]) == "{" {
			part = strings.ReplaceAll(part, "{", "")
			part = strings.ReplaceAll(part, "}", "")

			result += "By"

			for _, splitPart := range strings.Split(part, "_") {
				result += Title.String(splitPart)
			}
		}
	}

	return result
}

func FormatToGolangVarNameAndValue(sr ScrapeResult) string {
	sr = applyMutation(sr)

	return fmt.Sprintf(
		`var %s EndpointPattern = EndpointPattern{
	Pattern: "%s",
	Method:  "%s",
}
`,
		FormatToGolangVarName(sr),
		sr.EndpointPattern,
		strings.ToUpper(sr.HTTPMethod),
	) + "\n"
}
