# Largely inspired by:
# https://github.com/cachix/devenv/blob/main/src/modules/processes.nix
{ self, config, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    mkPerSystemOption;
  inherit (lib)
    mkOption
    mkDefault
    types;
  inherit (types)
    functionTo
    raw;
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
              };
            };
          };
          processGroupSubmodule = types.submodule {
            options = {
              processes = lib.mkOption {
                type = types.attrsOf processSubmodule;
              };
            };
          };
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
              find_up() {
                ancestors=()
                while true; do
                  if [[ -f $1 ]]; then
                    echo "$PWD"
                    exit 0
                  fi
                  ancestors+=("$PWD")
                  if [[ $PWD == / ]] || [[ $PWD == // ]]; then
                    echo "ERROR: Unable to locate the projectRootFile ($1) in any of: ''${ancestors[*]@Q}" >&2
                    exit 1
                  fi
                  cd ..
                done
              }
              # TODO: make configurable
              tree_root=$(find_up "flake.nix")

              # Pass user's arguments to honcho; if none was passed, pass
              # 'start' to launch all processes.
              ARG1="''${1:-start}"
              shift 1 || true

              set -x
              honcho --procfile ${procfile} --app-root="$tree_root" "$ARG1" "$@" 
            '';
          };
      in
      {
        inherit packages;
      };
  };
}
