{
  buildGoApplication,
  lib,
  version,
}:
buildGoApplication {
  inherit version;
  pname = "generate";
  src = lib.cleanSource ../.;
  modules = ./gomod2nix.toml;
  subPackages = [ "." ];
}
