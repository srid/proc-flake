{ flake-root }:
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
  _file = __curPos.file;
  imports = [
    flake-root.flakeModule
  ];
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }:
        let
          procSubmodule = types.submodule {
            options = {
              groups = lib.mkOption {
                type = types.attrsOf processGroupSubmodule;
                description = lib.mdDoc ''
                  Process groups that can be invoked individually.
                '';
              };
            };
          };
          processGroupSubmodule = types.submodule {
            options = {
              processes = lib.mkOption {
                type = types.attrsOf processSubmodule;
                description = lib.mdDoc ''
                  Processes to run simultaneously when running this group.
                '';
              };
            };
          };
          processSubmodule = types.submodule {
            options = {
              command = lib.mkOption {
                type = types.str;
                description = lib.mdDoc ''
                  The command to run the given process.
                '';
              };
            };
          };
        in
        {
          options.proc = lib.mkOption {
            type = procSubmodule;
            description = lib.mdDoc ''
              Configuration for processes to run in the development environment.
            '';
          };
        });
  };
  config = {
    perSystem = { config, self', inputs', pkgs, ... }:
      let
        packages = pkgs.lib.concatMapAttrs
          (k: v: {
            ${k} = processGroupCommand k v.processes;
          })
          config.proc.groups;
        processGroupCommand = name: procs:
          let
            procfile =
              pkgs.writeText "Procfile" (lib.concatStringsSep "\n"
                (lib.mapAttrsToList (name: v: "${name}: ${v.command}")
                  procs));
          in
          pkgs.writeShellApplication {
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
      in
      {
        proc = { inherit packages; };
      };
  };
}
