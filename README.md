# NixOS Configuration

This configuration follows the **dendritic pattern** — a way of organising NixOS
configs that mirrors how neurons work. A dendrite is a tree of branches that each
carry a signal into the central body. Here, every `.nix` file in `modules/` is an
independent branch that contributes one small piece to the final flake output,
with no central file manually listing them all.

---

## Directory structure

```
.
├── flake.nix                          # Root — 1 line of real logic
├── flake.lock                         # Pinned input versions (auto-managed)
├── config/                            # Raw dotfiles (symlinked at runtime)
│   ├── foot/  hypr/  waybar/  ...
│   └── starship.toml
└── modules/                           # Everything auto-loaded by import-tree
    ├── home-modules.nix               # Declares the homeModules flake output
    ├── hosts/
    │   ├── laptop/
    │   │   ├── default.nix            # Builds nixosConfigurations.laptop-host
    │   │   ├── configuration.nix      # Defines nixosModules.laptopConfiguration
    │   │   └── hardware.nix           # Defines nixosModules.laptopHardware
    │   └── vm/
    │       ├── default.nix            # Builds nixosConfigurations.vm-host
    │       ├── configuration.nix      # Defines nixosModules.vmConfiguration
    │       └── hardware.nix           # Defines nixosModules.vmHardware
    └── features/
        ├── nixos/                     # System-level features → nixosModules.*
        │   ├── nix.nix                #   nixSettings
        │   ├── locale.nix             #   locale
        │   ├── users.nix              #   users
        │   ├── hyprland.nix           #   hyprland
        │   ├── bluetooth.nix          #   bluetooth
        │   ├── networking.nix         #   networking
        │   ├── audio.nix              #   audio
        │   ├── virtualisation.nix     #   virtualisation
        │   ├── power.nix              #   power
        │   ├── fonts.nix              #   fonts
        │   ├── packages.nix           #   systemPackages
        │   └── security.nix           #   security
        └── home/                      # User-level features → homeModules.*
            ├── core.nix               #   core
            ├── packages.nix           #   packages
            ├── git.nix                #   git
            ├── shell.nix              #   shell
            ├── desktop.nix            #   homeDesktop
            ├── input.nix              #   inputMethod
            └── editors/
                ├── helix.nix          #   helix
                └── zed.nix            #   zed
```

---

## The flake — entry point

```nix
# flake.nix
outputs = inputs: inputs.flake-parts.lib.mkFlake
  { inherit inputs; }
  (inputs.import-tree ./modules);
```

That single line is the entire outputs definition. Two libraries do the heavy
lifting:

### `import-tree`

`import-tree ./modules` recursively walks the `modules/` directory, finds every
`.nix` file, imports each one, and returns them as a single merged
[flake-parts](https://flake.parts) module. This means:

- **Adding a feature** = drop a `.nix` file anywhere under `modules/`. Done.
- **Removing a feature** = delete the file. Done.
- There is no central `imports = [ ... ]` list to keep in sync.

### `flake-parts`

`flake-parts` is a framework for composing flake outputs from many independent
modules. It provides:

- A standard way to define flake outputs (`nixosConfigurations`, `nixosModules`,
  `homeModules`, `packages`, …) across many files without conflicts.
- The `self` reference — every module gets access to the fully-evaluated flake
  via `self`, which is how modules reference each other by name.
- Option-type merging — when multiple files each define one key of
  `flake.nixosModules`, flake-parts merges them into one attrset automatically.

---

## Two kinds of modules

Every file under `modules/` is a **flake-parts module**: a function that takes
`{ self, inputs, lib, ... }` and returns a small contribution to the flake
outputs. There are two flavours in use here.

### NixOS modules — `flake.nixosModules.*`

A file that contributes a NixOS module looks like this:

```nix
# modules/features/nixos/nix.nix
{ ... }: {
  flake.nixosModules.nixSettings = { ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.gc = { automatic = true; dates = "weekly"; };
  };
}
```

The **outer function** (`{ ... }:`) is the flake-parts module — it receives
`self`, `inputs`, etc. from flake-parts.

The **inner function** (`{ ... }:`) is the actual NixOS module — it receives
`pkgs`, `lib`, `config`, etc. from the NixOS module system when a machine is
built.

The name `nixSettings` becomes a key in `self.nixosModules`, so any host can
pull it in with `imports = [ self.nixosModules.nixSettings ]`.

### Home Manager modules — `flake.homeModules.*`

The same two-layer pattern, but for Home Manager:

```nix
# modules/features/home/editors/helix.nix
{ ... }: {
  flake.homeModules.helix = { pkgs, lib, ... }: {
    programs.helix = { enable = true; /* ... */ };
  };
}
```

`homeModules` is not a built-in flake-parts output (unlike `nixosModules`), so
`modules/home-modules.nix` declares it as a proper mergeable option:

```nix
# modules/home-modules.nix
{ lib, ... }: {
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = { };
  };
}
```

Without this declaration, flake-parts would not know that definitions of
`flake.homeModules` from separate files should be merged — it would error
instead. With it, each file can safely define one key and they all merge cleanly.

---

## Host machines

Each machine lives in `modules/hosts/<name>/` and is split across three files.

### `default.nix` — the assembly point

This is the only file that calls `nixpkgs.lib.nixosSystem`. It wires together:

1. The machine's NixOS configuration module (via `self.nixosModules`)
2. The Home Manager NixOS module (from `inputs`)
3. The inline Home Manager user config (via `self.homeModules`)

```nix
# modules/hosts/laptop/default.nix
{ self, inputs, ... }: {
  flake.nixosConfigurations.laptop-host = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.laptopConfiguration     # ← from configuration.nix
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.users.madeinshinea = {
          imports = [
            self.homeModules.core
            self.homeModules.shell
            self.homeModules.helix
            # ...
          ];
        };
      }
    ];
  };
}
```

`pkgs-unstable` is instantiated here and passed down via `extraSpecialArgs`, so
Home Manager modules that need unstable packages can just declare
`{ pkgs-unstable, ... }` in their argument list.

### `configuration.nix` — NixOS options for this machine

Defines `flake.nixosModules.laptopConfiguration`, which is a NixOS module that
imports all the feature modules and sets the few things that are truly
machine-specific (hostname, bootloader):

```nix
{ self, ... }: {
  flake.nixosModules.laptopConfiguration = { ... }: {
    imports = [
      self.nixosModules.laptopHardware
      self.nixosModules.nixSettings
      self.nixosModules.hyprland
      # ... all shared features ...
    ];

    networking.hostName = "laptop-host";
    boot.loader.systemd-boot.enable = true;
    system.stateVersion = "25.11";
  };
}
```

### `hardware.nix` — hardware configuration

Wraps the machine's hardware config (what `nixos-generate-config` normally
produces) inside a flake-parts module, so `import-tree` can load it correctly:

```nix
{ ... }: {
  flake.nixosModules.laptopHardware = { config, lib, modulesPath, ... }: {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" /* ... */ ];
    fileSystems."/" = { device = "/dev/disk/by-uuid/..."; fsType = "ext4"; };
    # ...
  };
}
```

---

## Features

Feature files are the leaves of the tree. Each one does exactly one thing.

### NixOS features (`modules/features/nixos/`)

| File | Module name | What it does |
|---|---|---|
| `nix.nix` | `nixSettings` | Enables flakes, pipe-operators, weekly GC |
| `locale.nix` | `locale` | Timezone (Zurich), Swiss-FR keyboard |
| `users.nix` | `users` | `madeinshinea` user account, nushell shell |
| `hyprland.nix` | `hyprland` | Hyprland + XWayland |
| `bluetooth.nix` | `bluetooth` | Bluetooth (off at boot) |
| `networking.nix` | `networking` | NetworkManager, Tailscale, Mullvad |
| `audio.nix` | `audio` | PipeWire pulse sink |
| `virtualisation.nix` | `virtualisation` | Podman with Docker compat |
| `power.nix` | `power` | TLP + thermald, battery charge thresholds |
| `fonts.nix` | `fonts` | JetBrainsMono Nerd Font |
| `packages.nix` | `systemPackages` | System-wide CLI and GUI packages |
| `security.nix` | `security` | Logind: lock on lid close, ignore power key |

### Home Manager features (`modules/features/home/`)

| File | Module name | What it does |
|---|---|---|
| `core.nix` | `core` | Username, home directory, XDG dirs, stateVersion |
| `packages.nix` | `packages` | User packages (mix of stable and unstable) |
| `git.nix` | `git` | Git identity |
| `shell.nix` | `shell` | Nushell, Starship, Direnv, Carapace, Tmux |
| `editors/helix.nix` | `helix` | Helix editor — languages, LSPs, theme |
| `editors/zed.nix` | `zed` | Zed editor — extensions, keymaps, agents |
| `desktop.nix` | `homeDesktop` | Swappy, Anki, dotfile symlinks |
| `input.nix` | `inputMethod` | Fcitx5 with Mozc (Japanese input) |

---

## How evaluation flows

When you run `nixos-rebuild switch --flake .#laptop-host`, Nix traces this path:

```
flake.nix
  └── import-tree ./modules           # discovers all .nix files
        └── (merged flake-parts module)
              ├── flake.nixosModules.nixSettings    = { ... nix settings ... }
              ├── flake.nixosModules.hyprland       = { ... }
              ├── flake.nixosModules.laptopHardware = { ... }
              ├── flake.nixosModules.laptopConfiguration = { imports = [...]; hostname = ...; }
              ├── flake.homeModules.helix           = { ... }
              ├── flake.homeModules.shell           = { ... }
              │   ... (all other modules) ...
              └── flake.nixosConfigurations.laptop-host
                    └── nixpkgs.lib.nixosSystem {
                          modules = [
                            self.nixosModules.laptopConfiguration   ← pulls in all nixos features
                            home-manager NixOS module
                            { home-manager.users.madeinshinea.imports = [
                                self.homeModules.core
                                self.homeModules.shell
                                ...                                 ← pulls in all home features
                              ]; }
                          ]
                        }
```

Everything is lazy — Nix only evaluates what is actually reachable from
`nixosConfigurations.laptop-host`. Files that define unused modules are imported
but their inner NixOS/HM module functions are never called.

---

## How to add a new machine

1. Create `modules/hosts/mymachine/` with three files:
   - `hardware.nix` — wrap your `nixos-generate-config` output inside
     `flake.nixosModules.mymachineHardware = { ... }: { ... };`
   - `configuration.nix` — define `flake.nixosModules.mymachineConfiguration`,
     import the features you want, set hostname + bootloader + stateVersion
   - `default.nix` — define `flake.nixosConfigurations.mymachine`, call
     `nixpkgs.lib.nixosSystem` with `self.nixosModules.mymachineConfiguration`
     and the home modules you want for the user

2. That's it. `import-tree` picks up the new directory automatically.
   Run `nixos-rebuild switch --flake .#mymachine`.

---

## How to add a new feature

### New NixOS feature

Create `modules/features/nixos/myfeature.nix`:

```nix
{ ... }: {
  flake.nixosModules.myFeature = { pkgs, ... }: {
    # your NixOS config here
  };
}
```

Then add `self.nixosModules.myFeature` to the `imports` list in whichever
host's `configuration.nix` should use it.

### New Home Manager feature

Create `modules/features/home/myfeature.nix`:

```nix
{ ... }: {
  flake.homeModules.myFeature = { pkgs, ... }: {
    # your Home Manager config here
  };
}
```

Then add `self.homeModules.myFeature` to the `imports` list inside
`users.madeinshinea` in whichever host's `default.nix` should use it.

---

## Inputs

| Input | Pinned to | Purpose |
|---|---|---|
| `nixpkgs` | `nixos-25.11` | Stable package set, NixOS base |
| `nixpkgs-unstable` | `nixos-unstable` | Bleeding-edge packages (Zed, OpenCode, Zellij, …) |
| `home-manager` | `release-25.11` | User environment management, follows stable nixpkgs |
| `flake-parts` | latest | Flake module composition framework |
| `import-tree` | latest | Auto-discovery of all `.nix` files under `modules/` |

`nixpkgs-unstable` is instantiated once in each host's `default.nix` and
injected into Home Manager via `extraSpecialArgs`. Any Home Manager module that
needs an unstable package simply declares `pkgs-unstable` in its argument list —
no extra wiring needed.

---

## Dotfiles (`config/`)

The `config/` directory holds raw config files for programs that don't have a
Home Manager option (or where you prefer editing plain files). The
`homeDesktop` Home Manager module creates **out-of-store symlinks** pointing
from `~/.config/<name>` into `~/nixos/config/<name>`:

```nix
xdg.configFile = builtins.mapAttrs (_name: subpath: {
  source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${subpath}";
  recursive = true;
}) { foot = "foot"; hypr = "hypr"; waybar = "waybar"; /* ... */ };
```

An *out-of-store symlink* means the target is your live checkout on disk, not a
read-only path in `/nix/store`. You can edit files in `config/` and the changes
take effect immediately without rebuilding.

---

## Rebuilding

```sh
# Apply configuration to the current machine
sudo nixos-rebuild switch --flake .#laptop-host
sudo nixos-rebuild switch --flake .#vm-host

# Check the config evaluates without building anything
nix flake check --no-build

# Update all inputs to their latest pinned versions
nix flake update
```
