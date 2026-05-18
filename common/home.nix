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
    #niri = "niri";
    #noctalia = "noctalia";
    opencode = "opencode";
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
    qbittorrent-enhanced

    # Japanese fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    wl-clipboard

    # Nix lsp
    nixd
    nil

    # Unstable packages
    pkgs-unstable.jujutsu
    pkgs-unstable.opencode

    pkgs-unstable.zellij

    pkgs-unstable.cherry-studio
    pkgs-unstable.ollama

    pkgs-unstable.remnote

    pkgs-unstable.bitwarden-desktop

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
    shellAliases = {
      zed = "zeditor .";
    };

    extraConfig = ''
      let env_path = ($env.HOME | path join "nixos" ".env")

      if ($env_path | path exists) {
        # 1. Read and clean lines
        let lines = (open $env_path --raw | lines | each { |l| $l | str trim } | where { |l| $l != "" and not ($l | str starts-with "#") })

        # 2. Parse into a record { KEY: "VALUE" }
        let env_record = ($lines
          | parse "{key}={value}"
          | reduce -f {} { |it acc|
              let k = ($it.key | str trim)
              let v = ($it.value | str trim | str replace --all '"' "" | str replace --all "'" "")
              $acc | upsert $k $v
            }
        )

        # 3. Load the record into the environment
        load-env $env_record
      }
    '';

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
      "nu"
    ];

    installRemoteServer = true;

    userSettings = {
      telemetry = {
        metrics = false;
      };

      git_panel = {
        dock = "left";
      };

      debugger = {
        dock = "left";
      };
      project_panel = {
        dock = "left";
      };

      agent_panel = {
        dock = "right";
      };

      agent = {
        sidebar_side = "right";
        dock = "right";
      };

      disable_ai = false;

      agent_servers = {
        OpenCode = {
          command = "opencode";
          args = [ "acp" ];
        };
      };

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

  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;

  home.stateVersion = "25.11";
}
