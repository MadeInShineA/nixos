# Load the project's direnv environment inside Neovim, so tools added to a
# project flake are picked up without restarting: run :DirenvExport (also
# done automatically on startup and when changing directory).
# Language servers whose binary appears are then started (see ./lsp.nix).
{
  flake.modules.nixvim.nvim = {
    plugins.direnv.enable = true;

    autoCmd = [
      {
        event = "User";
        pattern = "DirenvLoaded";
        callback.__raw = "function() _G.enable_available_lsp_servers() end";
      }
    ];
  };
}
