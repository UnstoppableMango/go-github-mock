build:
	nix build .#

gomod2nix.toml:
	gomod2nix generate
