# Largely inspired by:
# https://github.com/cachix/devenv/blob/main/src/modules/processes.nix
{ self, config, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    types;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }:
        let
          procSubmodule = types.submodule {
            options = {
              groups = lib.mkOption {
                type = types.attrsOf processGroupSubmodule;
                description = ''
                  Process groups that can be invoked individually.
                '';
              };
            };
          };
          processGroupSubmodule = types.submodule (args@{ name, ... }: {
            options = {
              processes = lib.mkOption {
                type = types.attrsOf processSubmodule;
                description = ''
                  Processes to run simultaneously when running this group.
                '';
              };
              package = lib.mkOption {
                type = types.package;
                description = ''
                  The package to use to run the given process group.
                '';
              };
            };
            config =
              let
                procfile =
                  pkgs.writeText "Procfile" (lib.concatStringsSep "\n"
                    (lib.mapAttrsToList (name: v: "${name}: ${v.command}")
                      args.config.processes));
              in
              {
                package = pkgs.writeShellApplication {
                  inherit name;
                  runtimeInputs = [ pkgs.honcho ];
                  text = ''
                    tree_root=''$(${lib.getExe config.flake-root.package})
                    cd "$tree_root"

                    # Pass user's arguments to honcho; if none was passed, pass
                    # 'start' to launch all processes.
                    ARG1="''${1:-start}"
                    shift 1 || true

                    set -x
                    honcho --procfile ${procfile} "$ARG1" "$@" 
                  '';
                };
              };
          });
          processSubmodule = types.submodule {
            options = {
              command = lib.mkOption {
                type = types.str;
                description = ''
                  The command to run the given process.
                '';
              };
            };
          };
        in
        {
          options.proc = lib.mkOption {
            type = procSubmodule;
            description = ''
              Configuration for processes to run in the development environment.
            '';
          };
        });
  };
}
