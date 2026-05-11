{
  buildGoApplication,
  lib,
  version,
}:
buildGoApplication {
  inherit version;
  pname = "mock";
  src = lib.cleanSource ../.;
  modules = ./gomod2nix.toml;
  subPackages = [ "src/mock" ];
}
