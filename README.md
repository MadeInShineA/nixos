# nixos

My NixOS + home-manager configuration, using the
[dendritic pattern](https://github.com/mightyiam/dendritic):
every `.nix` file under `modules/` is a [flake-parts](https://flake.parts) module,
loaded automatically by [import-tree](https://github.com/vic/import-tree).

## Run my apps anywhere

```sh
nix run github:MadeInShineA/nixos#nvim
nix run github:MadeInShineA/nixos#nushell
```

## Layout

| Path | Contents |
|---|---|
| `flake.nix` | inputs only; outputs = `import-tree ./modules` |
| `modules/flake-parts.nix` | systems, nixpkgs for `packages` |
| `modules/hosts/<host>/` | a machine: the aspects it uses + machine-only settings |
| `modules/users/` | user account + home profile, `home-manager` and `dotfiles` aspects |
| `modules/{system,desktop,shell,editors,dev,apps}/` | features ("aspects") |
| `modules/lib/standalone.nix` | helpers turning an aspect into a `nix run` package |
| `config/` | raw dotfiles, linked live into `~/.config` |

A feature file defines one or more of:

- `flake.modules.nixos.<name>`: system part, picked by hosts
- `flake.modules.homeManager.<name>`: user part (a system part adds it for every user
  via `home-manager.sharedModules`; user-only aspects are picked in the user profile)
- `perSystem.packages.<name>`: the app with its config, for `nix run`

Files or directories starting with `_` are not imported (e.g. `_hardware-configuration.nix`).

## Apply

```sh
nh os switch .            # or: sudo nixos-rebuild switch --flake .#laptop-host
```
