{
  description = "A `flake-parts` module for running Procfile-like processes";
  outputs = { self, ... }: {
    flakeModule = ./flake-module.nix;
  };
}
