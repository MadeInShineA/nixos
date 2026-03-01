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

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    pictures = "${config.home.homeDirectory}/Pictures";
  };

  # Universal user packages
  home.packages = with pkgs; [
    fastfetch

    yazi

    vesktop
    telegram-desktop
    opencode

    wl-clipboard

    super-productivity

    # Re use words lsp
    simple-completion-language-server

    # Spell checker lsp
    codebook

    # Nix LSP
    nil

    # Markdown LSP
    marksman
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

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = true;
  };

  programs.nushell = {
    enable = true;

    environmentVariables = {
      EDITOR = "hx";
      VIEW = "hx";
    };

    settings = {
      show_banner = false;
    };
  };

  programs.swappy = {
    enable = true;
    settings = {
      Default = {
        save_dir = "${config.xdg.userDirs.pictures}";
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
            kotlin.enable = true;
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
    defaultEditor = true;
    settings = {
      theme = "catppuccin_mocha_transparent";

      editor.bufferline = "multiple";
      editor.line-number = "relative";
      editor.inline-diagnostics.cursor-line = "warning";
      editor.inline-diagnostics.other-lines = "warning";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };

    languages = {
      language-server = {
        codebook = {
          command = "codebook-lsp";
          args = [ "serve" ];
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
          language-servers = [ "nil" ];
        }
        {
          name = "markdown";
          auto-format = true;
          formatter = {
            command = lib.getExe pkgs.deno;
            args = [
              "fmt"
              "-"
              "--ext"
              "md"
            ];
          };
          language-servers = [
            "marksman"
            "codebook"
          ];
          file-types = [
            "md"
            "mdx"
            "qmd"
          ];
        }
      ];
    };
    themes = {
      catppuccin_mocha_transparent = {
        "inherits" = "catppuccin_mocha";
        "ui.background" = { };
      };
    };

    extraPackages = [
      pkgs.simple-completion-language-server
      pkgs.codebook
    ];
  };

  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;

  home.stateVersion = "25.11";
}
