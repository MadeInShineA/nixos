# Autocompletion menu (LSP, paths, snippets, buffer words)
{
  flake.modules.nixvim.nvim = {
    plugins = {
      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "default";
          completion.documentation.auto_show = true;
          signature.enabled = true;
          sources.default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
      };

      # Ready-made snippets for many languages
      friendly-snippets.enable = true;
    };
  };
}
