# proc-flake

A [`flake-parts`](https://flake.parts/) Nix module for running multiple processes in a dev shell.

[honcho](https://github.com/nickstenning/honcho) is used to launch the processes.

## Usage

NOTE: this module requires the [flake-root](https://github.com/srid/flake-root) module.

```nix
proc.groups.run.processes = {
  haskell.command = "${lib.getExe pkgs.haskellPackages.ghcid}";
  tailwind.command = "${lib.getExe pkgs.haskellPackages.tailwind} -w -o ./static/tailwind.css './src/**/*.hs'";
};

```

This gives a `proc.groups.run.package` derivation that you can put in the `nativeBuildInputs` of devShell for availability in the shell.

For better discoverability, consider using this in conjunction with the [mission-control](https://github.com/Platonic-Systems/mission-control) module.

## Examples

- https://github.com/EmaApps/ema-template/pull/40

## Credits

The idea for this module came largely from Domen Kožar's [devenv project](https://devenv.sh/processes/). 

## Alternatives

For a similar module that uses a more advanced tool called `process-compose`, see https://github.com/Platonic-Systems/process-compose-flake
