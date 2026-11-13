# File tree on the left
{
  flake.modules.nixvim.nvim = {
    # Disable netrw so it doesn't flash before neo-tree hijacks `nvim <dir>`
    globals = {
      loaded_netrw = 1;
      loaded_netrwPlugin = 1;
    };

    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        window = {
          position = "left";
          width = 32;
        };
        filesystem = {
          follow_current_file.enabled = true;
          filtered_items = {
            visible = true;
            hide_dotfiles = false;
          };
          use_libuv_file_watcher = true;
          window.mappings = {
            # yazi-like navigation
            "l" = "open"; # expand folder / open file
            "h" = "close_node"; # collapse folder, or jump to and collapse parent
            "L" = "set_root"; # cd into folder
            "H" = "navigate_up"; # cd to parent directory
            "." = "toggle_hidden";
          };
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "File tree";
      }
    ];
  };
}
