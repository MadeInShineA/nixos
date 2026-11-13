# Raw dotfiles live in ./config. Aspects link them with `config.dotfiles.link "<name>"`:
# - on hosts (mutable = true): out-of-store symlink into the checkout, so they can
#   be edited live (and written to by the apps) without a rebuild
# - standalone packages (mutable = false): a copy in the store, as committed
{
  flake.modules.homeManager.dotfiles =
    { config, lib, ... }:
    {
      options.dotfiles = {
        mutable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Link dotfiles from the checkout (true) or copy them into the store (false).";
        };

        dir = lib.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/nixos/config";
          description = "Location of ./config in the checkout (used when mutable).";
        };

        link = lib.mkOption {
          type = lib.types.functionTo lib.types.raw;
          readOnly = true;
          default =
            subpath:
            if config.dotfiles.mutable then
              config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${subpath}"
            else
              builtins.path {
                name = lib.replaceStrings [ "/" ] [ "-" ] subpath;
                path = ../../config + "/${subpath}";
              };
          description = "Source for a path inside ./config, to use in `home.file`/`xdg.configFile`.";
        };
      };
    };
}
