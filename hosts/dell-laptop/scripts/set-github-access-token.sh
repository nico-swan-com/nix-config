#!/bin/sh

# Validate an existing token if one is already in the environment.
if [ -n "$GITHUB_TOKEN" ]; then
	if ! GITHUB_TOKEN="$GITHUB_TOKEN" nix run nixpkgs#gh api user >/dev/null 2>&1; then
		unset GITHUB_TOKEN
	fi
fi

# If no valid env token is present, use gh auth and extract token.
if [ -z "$GITHUB_TOKEN" ]; then
	nix run nixpkgs#gh auth status >/dev/null 2>&1 || nix run nixpkgs#gh auth login
	GITHUB_TOKEN="$(nix run nixpkgs#gh auth token)"
	export GITHUB_TOKEN
fi

# Ensure the token we are about to export works for GitHub API calls.
if ! GITHUB_TOKEN="$GITHUB_TOKEN" nix run nixpkgs#gh api user >/dev/null 2>&1; then
	echo "GitHub token is invalid. Re-run and complete gh auth login." >&2
	return 1 2>/dev/null || exit 1
fi

export NIX_CONFIG="access-tokens = github.com=$GITHUB_TOKEN"
