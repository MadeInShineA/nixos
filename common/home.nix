{
  config,
  pkgs,
  pkgs-unstable,
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

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  # Universal user packages
  home.packages = with pkgs; [
    fastfetch
    btop

    yazi

    vesktop
    telegram-desktop
    opencode
    qbittorrent-enhanced

    # Japanese fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    wl-clipboard

    super-productivity

    # Nix lsp
    nixd
    nil

    # Unstable packages
    pkgs-unstable.jujutsu

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

  programs.tmux = {
    enable = true;
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

  programs.carapace = {
    enable = true;
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

  programs.anki = {
    enable = true;
    theme = "dark";

    addons = with pkgs.ankiAddons; [
      (anki-connect.withConfig {
        config = {
          webCorsOriginList = [
            "http://localhost"
            "http://localhost:8765"
            "http://localhost:3000"
            "https://app.asbplayer.dev"
          ];
        };
      })
    ];
  };

  programs.zed-editor = {
    enable = true;

    package = pkgs-unstable.zed-editor;

    extensions = [
      "nix"
      "catppuccin"
      "quarto"
      "typst"
      "codebook"
      "comment"
      "toml"
      "vue"
      "php"
    ];

    installRemoteServer = true;

    userSettings = {
      telemetry = {
        metrics = false;
      };

      disable_ai = true;

      colorize_brackets = true;

      theme = "Catppuccin Mocha";
      helix_mode = true;

      inlay_hints = {
        enabled = true;
        show_type_hints = true;
        show_parameter_hints = true;
      };

      ui_font_size = 16;

      buffer_font_family = "JetBrainsMono Nerd Font";
      buffer_font_size = 16;

      terminal = {
        font_family = "JetBrainsMono Nerd Font";
      };

      lsp = {
        rust-analyzer = {
          initialization_options = {
            check = {
              command = "clippy";
            };
          };
        };
      };
    };
  };

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
      editor.file-picker.hidden = false;
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
          language-servers = [ "nixd" ];
        }
        {
          name = "rust";
          auto-format = true;
          formatter.command = lib.getExe pkgs.clippy;
          language-servers = [ "rust-analyzer" ];

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
