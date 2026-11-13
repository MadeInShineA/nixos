# Neovim, fully configured and self-contained (plugins + init.lua baked in).
#
#   nix run github:MadeInShineA/nixos#nvim
#
# Plugins come from nixpkgs (no plugin manager, treesitter grammars prebuilt).
# Language servers are NOT bundled: they are expected to come from project
# flakes (direnv); a server is only enabled when its binary is on PATH.
let
  mkNvim =
    pkgs:
    pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
      viAlias = true;
      vimAlias = true;
      withRuby = false;
      withPython3 = false;

      luaRcContent = builtins.readFile ./init.lua;

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
        # Toggleable (floating) terminal
        toggleterm-nvim
      ];

      # Tools nvim relies on, appended to PATH (anything already on PATH wins)
      wrapperArgs = [
        "--suffix"
        "PATH"
        ":"
        (pkgs.lib.makeBinPath [
          pkgs.nixfmt # formatter used by conform / nixd
          pkgs.ripgrep # telescope live_grep
          pkgs.fd # telescope find_files
        ])
      ];
    };
in
{
  # nix run .#nvim
  perSystem =
    { pkgs, ... }:
    {
      packages.nvim = mkNvim pkgs;
    };

  # Same package on hosts, as the default editor
  flake.modules.homeManager.nvim =
    { pkgs, ... }:
    let
      editor = {
        EDITOR = "nvim";
        VIEW = "nvim";
      };
    in
    {
      home.packages = [ (mkNvim pkgs) ];
      home.sessionVariables = editor;
      programs.nushell.environmentVariables = editor;
    };
}
