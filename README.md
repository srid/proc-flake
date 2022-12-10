# proc-flake

A [`flake-parts`](https://flake.parts/) Nix module for running multiple processes in a dev shell.

## Example

```nix
proc.groups.run.processes = {
  haskell.command = "${lib.getExe pkgs.haskellPackages.ghcid}";
  tailwind.command = "${lib.getExe pkgs.haskellPackages.tailwind} -w -o ./static/tailwind.css './src/**/*.hs'";
};

```

Then, after you put `config.packages.run` (because "run" is the group name) to the buildInputs of your devShell, you will be able to run `run` from inside of the nix shell to be able to spin up the processes using foreman.

## Credits

The idea for this module came largely from Domen Kožar's [devenv project](https://devenv.sh/processes/). 

## Alternatives

For a similar module that uses a more advanced tool called `process-compose`, see https://github.com/Platonic-Systems/process-compose-flake
