{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    #set colorscheme
    colorschemes.gruvbox = {
      enable = true;
      settings = {
        contrastDark = "soft";
        improvedStrings = true;
        improvedWarnings = true;
        trueColor = true;
      };
    };

    globals = {
      mapleader = ",";
      maplocalleader = " ";
      #for vimtex
      vimtex_view_general_viewer = "okular";
      vimtex_view_general_options = "--unique file:@pdf\#src:@line@tex";

      # for custom build and run commands
      dir = "%:p:h";
      folder = "%:p:h:t";
      file = "%:t";
    };

    #clipboard support
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    opts = {
      compatible = false; #disable compatibility to old-time vi
      showmatch = true; #show matching
      ignorecase = true; #case insensitive
      mouse = "a"; #enable mouse for all modes
      hlsearch = true; #highlight search
      incsearch = true; #incremental search
      tabstop = 4; #how wide tab character should be displayed
      softtabstop = 0; #how wide pressing tab should span (replicate tabstop)
      shiftwidth = 0; #how wide shift commands should be (replicate tabstop)
      expandtab = true; #converts tabs to white space
      shiftround = true; #round indentation to multiples shiftwidth
      autoindent = true; #indent a new line the same amount as the line just typed
      smartindent = true; #make smart indentation (after { and so on)
      number = true; #add line numbers
      cursorline = true; #highlight current cursorline
      ttyfast = true; #Speed up scrolling in Vim
      ve = "onemore"; #allow cursor to be at first empty space after line
      encoding = "utf8";
    };
    autoCmd = [
      {
        #change indentation for .nix files
        event = [
          "BufEnter"
          "BufWinEnter"
        ];
        pattern = "*.nix"; #set tabstop of 2 for nix files
        # Or use `vimCallback` with a vimscript function name
        # Or use `command` if you want to run a normal vimscript command
        command = "setlocal tabstop=2";
      }
    ];

    keymaps = [
      #mode = "": for normal,visual,select,operator-pending modes (map)
      #mode = "n": for normal mode
      #mode = "i": for insert mode

      # set window navigation keys
      {
        mode = "";
        key = "<c-j>";
        action = "<c-w>j";
      }
      {
        mode = "";
        key = "<c-k>";
        action = "<c-w>k";
      }
      {
        mode = "";
        key = "<c-l>";
        action = "<c-w>l";
      }
      {
        mode = "";
        key = "<c-h>";
        action = "<c-w>h";
      }

      #for luasnips
      {
        mode = [
          ""
          "i"
        ];
        key = "<c-w>";
        action = "<cmd>lua require('luasnip').jump(1)<Cr>";
        options.silent = true;
      }
      {
        mode = [
          ""
          "i"
        ];
        key = "<c-b>";
        action = "<cmd>lua require('luasnip').jump(-1)<Cr>";
        options.silent = true;
      }
      {
        mode = [
          "i"
        ];
        key = "<c-u>";
        action = "<C-O>:update<CR>";
      }
      {
        mode = [
          ""
          "i"
        ];
        key = "<c-n>";
        action = "luasnip#choice_active() ? '<Plug>luasnip-next-choice'";
        options.silent = true;
      }

      #for custom build and run
      {
        mode = "n";
        key = "<Leader>bc";
        action = ":CreateCMakeFile<CR>";
      }
      {
        mode = "n";
        key = "<Leader>bd";
        action = ":BuildDebug<CR>";
      }
      {
        mode = "n";
        key = "<Leader>br";
        action = ":BuildRelease<CR>";
      }
      {
        mode = "n";
        key = "<Leader>rd";
        action = ":RunDebug<CR>";
      }
      {
        mode = "n";
        key = "<Leader>rr";
        action = ":RunRelease<CR>";
      }

      #for dap (debugging)
      {
        mode = "n";
        key = "<LocalLeader>c";
        action = ":DapContinue<CR>";
      }
      {
        mode = "n";
        key = "<LocalLeader>n";
        action = ":DapStepOver<CR>";
      }
      {
        mode = "n";
        key = "<LocalLeader>s";
        action = ":DapStepInto<CR>";
      }
      {
        mode = "n";
        key = "<LocalLeader>f";
        action = ":DapStepOut<CR>";
      }
      {
        mode = "n";
        key = "<LocalLeader>b";
        action = ":DapToggleBreakpoint<CR>";
      }
      {
        mode = "n";
        key = "<LocalLeader>q";
        action = ":DapTerminate<CR>";
      }

      #telescope
      {
        mode = "";
        key = "<LocalLeader>t";
        action = ":Telescope file_browser<CR>";
      }
    ];

    plugins = {
      #improved highlighting
      treesitter = {
        enable = true;
        disabledLanguages = [ "latex" ];
      };

      #shows indentation levels and variable scopes (treesitter)
      indent-blankline.enable = true;

      #automatically creates pairs of brackets, etc.
      nvim-autopairs.enable = true;

      #LaTeX support
      vimtex.enable = true;

      #file browser/switcher
      telescope = {
        enable = true;
        settings.defaults = {
          initial_mode = "normal";
          mappings.n = {
            "l" = "select_default";
          };
        };
        extensions.file-browser = {
          enable = true;
          settings.mappings = {
            "n" = {
              "h" = "goto_parent_dir";
            };
          };
        };
      };

      #theme for status bar at bottom
      lualine = {
        enable = true;
        theme = "gruvbox";
      };

      #snippet engine
      luasnip = {
        enable = true;
        fromVscode = [
          {
            include = [
              "bash"
              "c"
              "cpp"
              "python"
              "nix"
              "latex"
            ];
          }
        ];
      };

      #error highlighting and autocomplete (different language servers + luasnip config)
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true; #lsp server for Bash
          clangd.enable = true; #lsp server for C/C++
          pyright.enable = true; #lsp server for Python
          nil-ls.enable = true; #lsp server for Nix
          texlab.enable = true; #lsp Server for LaTeX
          java-language-server.enable = true; #lsp Server for Java
        };
      };
      cmp = {
        enable = true;
        settings = {
          snippet.expand = "luasnip";
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; } #For luasnip users.
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<CR>" = "cmp.mapping.confirm({select = true})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
        };
      };
    };
    #collection of default snippets
    extraPlugins = with pkgs.vimPlugins; [
      friendly-snippets
    ];

  };
}


