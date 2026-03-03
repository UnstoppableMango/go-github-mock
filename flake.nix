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
        {
          inputs',
          pkgs,
          lib,
          ...
        }:
        let
          inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication gomod2nix;

          generate = buildGoApplication {
            pname = "generate";
            version = "0.0.1";
            src = lib.cleanSource ./.;
            modules = ./gomod2nix.toml;
          };

          mock = buildGoApplication {
            pname = "mock";
            version = "0.0.1";
            src = lib.cleanSource ./.;
            modules = ./gomod2nix.toml;
            subPackages = [ "src/mock" ];
          };
        in
        {
          packages = {
            inherit generate mock;
            default = generate;
          };

          apps = {
            default = {
              type = "app";
              program = "${generate}/bin/generate";
            };

            gomod2nix = {
              type = "app";
              program = "${gomod2nix}/bin/gomod2nix";
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              gnumake
              go
              golangci-lint
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
