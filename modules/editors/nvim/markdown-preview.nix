# Live markdown preview in the browser (mermaid, KaTeX math), synced to the cursor
{
  flake.modules.nixvim.nvim = {
    plugins.markdown-preview.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>mp";
        action = "<cmd>MarkdownPreviewToggle<cr>";
        options.desc = "Markdown preview";
      }
    ];
  };
}
