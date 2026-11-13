# Diagnostics: inline, warnings and errors only
#
# Also built in: <C-w>d line diagnostics popup, ]d / [d next / prev diagnostic
{
  flake.modules.nixvim.nvim = {
    diagnostic.settings = {
      virtual_text.severity.min.__raw = "vim.diagnostic.severity.WARN";
      severity_sort = true;
      float.border = "rounded";
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>k";
        action.__raw = "vim.diagnostic.open_float";
        options.desc = "Line diagnostics";
      }
    ];
  };
}
