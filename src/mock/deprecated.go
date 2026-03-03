package mock

// Deprecated endpoints: GitHub's classic Projects API was removed from the
// GitHub REST API in 2024. These aliases are kept for backwards compatibility
// so existing code continues to compile, but the underlying GitHub API
// endpoints no longer exist. Migrate to the Projects V2 API; see
// https://docs.github.com/en/issues/planning-and-tracking-with-projects

// Deprecated: Use GetOrgsProjectsv2ByOrg instead.
// GitHub's classic Projects API has been removed.
var GetOrgsProjectsByOrg EndpointPattern = EndpointPattern{
	Pattern: "/orgs/{org}/projects",
	Method:  "GET",
}

// Deprecated: GitHub's classic Projects API has been removed.
var PostOrgsProjectsByOrg EndpointPattern = EndpointPattern{
	Pattern: "/orgs/{org}/projects",
	Method:  "POST",
}

// Deprecated: GitHub's classic Projects API has been removed.
var GetReposProjectsByOwnerByRepo EndpointPattern = EndpointPattern{
	Pattern: "/repos/{owner}/{repo}/projects",
	Method:  "GET",
}

// Deprecated: GitHub's classic Projects API has been removed.
var PostReposProjectsByOwnerByRepo EndpointPattern = EndpointPattern{
	Pattern: "/repos/{owner}/{repo}/projects",
	Method:  "POST",
}

// Deprecated: GitHub's classic Projects API has been removed.
var GetUsersProjectsByUsername EndpointPattern = EndpointPattern{
	Pattern: "/users/{username}/projects",
	Method:  "GET",
}

// Deprecated: GitHub's classic Projects API has been removed.
var PostUserProjects EndpointPattern = EndpointPattern{
	Pattern: "/user/projects",
	Method:  "POST",
}
