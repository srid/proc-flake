{
  description = "A `flake-parts` module for running Procfile-like processes";
  inputs = {
    flake-root.url = "github:srid/flake-root";
  };
  outputs = { self, flake-root, ... }: {
    flakeModule = import ./flake-module.nix { inherit flake-root; };
  };
}
