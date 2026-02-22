{
  config,
  pkgs,
  lib,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/nixos/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    foot = "foot";
    hypr = "hypr";
    waybar = "waybar";
    rofi = "rofi";
    mako = "mako";
    "starship.toml" = "starship.toml";
  };

in
{
  home.username = "madeinshinea";
  home.homeDirectory = "/home/madeinshinea";

  # Universal user packages
  home.packages = with pkgs; [
    fastfetch

    vesktop
    telegram-desktop

    wl-clipboard

    # Nix lsp
    nil
  ];

  # Universal user programs config
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Olivier Amacker";
        email = "olivier.amacker@netplus.ch";
      };
    };
  };

  /*
    programs.nvf = {
      enable = true;

      settings = {
        vim = {
          telescope.enable = true;

          statusline = {
            lualine.enable = true;
          };

          filetree = {
            neo-tree.enable = true;
          };

          autocomplete = {
            nvim-cmp.enable = true;
          };

          git = {
            enable = true;
            gitsigns.enable = true;
          };

          clipboard = {
            enable = true;
            registers = "unnamedplus";
          };

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
            transparent = true;
          };

          notify = {
            nvim-notify.enable = true;
          };

          tabline = {
            nvimBufferline.enable = true;
          };

          binds = {
            whichKey.enable = true;
            cheatsheet.enable = true;
          };

          lsp = {
            enable = true;
            formatOnSave = true;
            trouble.enable = true;
            lspSignature.enable = true;
          };

          languages = {
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;

            nix.enable = true;
            json.enable = true;
            markdown = {
              enable = true;
              extensions = {
                render-markdown-nvim.enable = true;
              };
            };
          };
        };
      };
    };
  */

  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_mocha_transparent";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
        language-servers = [ "nil" ];
      }
    ];
    themes = {
      catppuccin_mocha_transparent = {
        "inherits" = "catppuccin_mocha";
        "ui.background" = { };
      };
    };
  };

  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;

  home.stateVersion = "25.11";
}
