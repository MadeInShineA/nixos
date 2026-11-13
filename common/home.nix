{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/nixos/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    foot = "foot";
    # hypr = "hypr";
    # waybar = "waybar";
    # rofi = "rofi";
    cosmic = "cosmic";
    # mako = "mako";
    niri = "niri";
    noctalia = "noctalia";
    opencode = "opencode";
    yazi = "yazi";
    "starship.toml" = "starship.toml";
    "mimeapps.list" = "mimeapps.list";
  };

in
{

  /*
    imports = [
      # inputs.zen-browser.homeModules.default
    ];
  */

  home.username = "madeinshinea";
  home.homeDirectory = "/home/madeinshinea";

  /*
    programs.zen-browser = {
      enable = true;
      env.MOZ_ENABLE_WAYLAND = "0";
    };
  */

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
    pictures = "${config.home.homeDirectory}/Pictures";
  };

  # Universal user packages
  home.packages = with pkgs; [
    btop

    yazi

    vesktop
    telegram-desktop
    # qBittorrent with python3 on its PATH only (needed for search plugins)
    (symlinkJoin {
      name = "qbittorrent-enhanced";
      paths = [ qbittorrent-enhanced ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/qbittorrent --prefix PATH : ${python3}/bin
      '';
    })

    /*
      # Japanese fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    */

    # wl-clipboard

    # Nix lsp
    nixd
    nil

    prismlauncher
    horizon-launcher

    opencode

    # cherry-studio

    remnote

    bitwarden-desktop

    teams-for-linux

    turbovnc

    # awscli

    wl-clipboard

    ares

    librewolf

    azahar
    antimicrox

    # Comes from external flake
    claude-desktop-fhs
    claude-code

    stremio-linux-shell

    # For screen recording
    slurp

    # For yazi built-ins
    zoxide

    gh
    nh
    nitch

    p7zip

    thunderbird

    # Firefox forced to X11/XWayland (fixes mouse input in GeForce Now)
    (symlinkJoin {
      name = "firefox";
      paths = [ firefox ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/firefox --set MOZ_ENABLE_WAYLAND 0
      '';
    })

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

  services.wl-clip-persist.enable = true;

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

      # Run yazi with a POSIX SHELL so its `shell` commands (e.g. extraction) work
      def --env yazi [...args] { with-env { SHELL: "bash" } { ^yazi ...$args } }
    '';

    extraEnv = ''
      $env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin" | uniq)
      $env.XDG_SESSION_TYPE = "wayland"
    '';
  };

  /*
    programs.swappy = {
      enable = true;
      settings = {
        Default = {
          save_dir = "${config.xdg.userDirs.pictures}";
        };
      };
    };
  */

  programs.zed-editor = {
    enable = true;

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
      "dockerfile"
      "scala"
      "haskell"
      "r"
      "c"
      "cpp"
      "cuda"
      "gleam"
      "java"
      "go"
    ];

    installRemoteServer = true;

    userSettings = {
      format_on_save = "on";

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

      agent = {
        dock = "right";
      };

      disable_ai = false;

      agent_servers = {
        OpenCode = {
          command = "opencode";
          args = [ "acp" ];
        };
      };

      theme = "Catppuccin Mocha";
      helix_mode = true;

      inlay_hints = {
        enabled = true;
        show_type_hints = true;
        show_parameter_hints = true;
        show_other_hints = true;
      };

      diagnostics.inline = {
        enabled = true;
        max_severity = "warning";

      };

      ui_font_size = 16;

      buffer_font_family = "JetBrainsMono Nerd Font";
      buffer_font_size = 16;

      terminal = {
        font_family = "JetBrainsMono Nerd Font";
        shell = {
          program = "nu";
        };
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

      languages = {
        "C++" = {
          tab_size = 2;
          hard_tabs = false;
        };
      };
    };
  };

  programs.vscodium = {
    enable = true;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions =
        with pkgs.vscode-extensions;
        [
          jnoortheen.nix-ide
          mkhl.direnv
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          quarto.quarto
          myriad-dreamin.tinymist
          streetsidesoftware.code-spell-checker
          aaron-bond.better-comments
          tamasfe.even-better-toml
          vue.volar
          bmewburn.vscode-intelephense-client
          thenuprojectcontributors.vscode-nushell-lang
          ms-azuretools.vscode-docker
          scalameta.metals
          scala-lang.scala
          haskell.haskell
          justusadam.language-haskell
          reditorsupport.r
          llvm-vs-code-extensions.vscode-clangd
          gleam.gleam
          redhat.java
          golang.go
          rust-lang.rust-analyzer
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vscode-helix-emulation";
            publisher = "jasew";
            version = "0.6.2";
            sha256 = "14kgjfqik53lg0c1cqgv04pv3cs0kipm6w6wk88jdz2yasxx7zjp";
          }
        ];

      userSettings = {
        "editor.formatOnSave" = true;

        "telemetry.telemetryLevel" = "off";

        "workbench.sideBar.location" = "left";
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";

        "editor.bracketPairColorization.enabled" = true;

        "editor.inlayHints.enabled" = "on";

        "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        "editor.fontSize" = 16;
        "editor.fontLigatures" = true;

        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        "terminal.integrated.defaultProfile.linux" = "nu";
        "terminal.integrated.profiles.linux" = {
          nu = {
            path = "nu";
          };
        };

        "direnv.restart.automatic" = true;

        "rust-analyzer.check.command" = "clippy";

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";

        "[cpp]" = {
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
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
      editor.inline-diagnostics = {
        cursor-line = "warning";
        other-lines = "warning";
      };

      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      editor.file-picker.hidden = false;
    };

    languages = {
      language-server = {
        /*
          codebook = {
            command = "codebook-lsp";
            args = [ "serve" ];
          };
        */
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
            # "codebook"
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
    ];
  };

  # Neovim: plugins come from nixpkgs (no plugin manager needed, treesitter
  # grammars are prebuilt). Language servers are NOT installed here, they are
  # expected to come from project flakes (direnv); a server is only enabled
  # when its binary is on PATH.
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;

    plugins = with pkgs.vimPlugins; [
      # --- Core / UI ---

      # Catppuccin color scheme (mocha flavour)
      catppuccin-nvim
      # File type icons, used by the tree, statusline, bufferline, picker
      nvim-web-devicons
      # Status line at the bottom (mode, git branch, diagnostics, position)
      lualine-nvim
      # Open buffers shown as tabs at the top
      bufferline-nvim
      # Popup listing available keybindings after pressing a prefix (e.g. Space)
      which-key-nvim
      # Vertical indentation guides
      indent-blankline-nvim
      # LSP progress messages in the bottom-right corner
      fidget-nvim
      # Highlights and searches TODO / FIXME / NOTE comments
      todo-comments-nvim
      # Lua utility library required by telescope, neo-tree, todo-comments
      plenary-nvim

      # --- File tree + picker ---

      # File explorer side panel
      neo-tree-nvim
      # UI component library required by neo-tree
      nui-nvim
      # Fuzzy finder for files, text (grep), buffers, symbols, diagnostics...
      telescope-nvim
      # Native fzf sorter, makes telescope faster with fzf-like matching
      telescope-fzf-native-nvim

      # --- Editing ---

      # Treesitter with every grammar prebuilt (highlighting, indent, folding)
      nvim-treesitter.withAllGrammars
      # Automatically inserts the closing bracket / quote
      nvim-autopairs
      # Close buffers without closing the window they are shown in
      mini-bufremove
      # Autocompletion menu (LSP, paths, snippets, buffer words)
      blink-cmp
      # Collection of ready-made snippets for many languages, used by blink-cmp
      friendly-snippets

      # --- LSP / formatting ---

      # Default configs for language servers (servers come from project flakes)
      nvim-lspconfig
      # Format on save, with per-filetype formatters and LSP fallback
      conform-nvim

      # --- Git + terminal ---

      # Git change markers in the sign column, hunk preview / stage / blame
      gitsigns-nvim
      # Toggleable (floating) terminal running nushell
      toggleterm-nvim
    ];

    # Formatter used by conform/nixd (on nvim's PATH only)
    extraPackages = [ pkgs.nixfmt ];

    initLua = builtins.readFile ../config/nvim/init.lua;
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

  xdg.stateFile.noctalia.source = create_symlink "${dotfiles}/noctalia";

  home.stateVersion = "25.11";
}
