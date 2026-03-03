{
  description = "A library to aid unittesting code that uses Golang's Github SDK";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.inputs.systems.follows = "systems";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { inputs', pkgs, lib, ... }:
        let
          inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication gomod2nix;

	  go-github-mock = buildGoApplication {
            pname = "go-github-mock";
	    version = "0.0.1";
	    src = lib.cleanSource ./.;
	    modules = ./gomod2nix.toml;
	  };
        in
        {
	  packages = {
            inherit go-github-mock;
	    default = go-github-mock;
	  };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              gnumake
              go
	      gomod2nix
              nixfmt
            ];
          };

          treefmt = {
            programs.nixfmt.enable = true;
            programs.gofmt.enable = true;
          };
        };
    };
}
