{
  description = "debugloop/dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    niri-unstable = {
      url = "github:YaLTeR/niri/0bef1c6c3b44039dac2d858d57d49d8f0ca32c23";
      flake = false;
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.niri-unstable.follows = "niri-unstable";
    };

    # private flakes
    gridx.url = "git+ssh://git@github.com/debugloop/gridx";
    # gridx.url = "path:/home/danieln/code/gridx";
    wunschkonzert-install.url = "git+ssh://git@github.com/debugloop/wunschkonzert-install";
    # wunschkonzert-install.url = "path:/home/danieln/code/wunschkonzert-install";
  };

  outputs = inputs @ {nixpkgs, ...}: {
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };

    nixosConfigurations = {
      simmons = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          hostname = "simmons";
        };
        modules = [
          ./hosts/common
          ./hosts/common/laptops.nix
          ./hosts/simmons
        ];
      };

      lusus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          hostname = "lusus";
        };
        modules = [
          ./hosts/common
          ./hosts/common/laptops.nix
          ./hosts/lusus
          ({...}: {
            home-manager.users.danieln = {
              imports = [
                inputs.gridx.home-module
              ];
            };
          })
        ];
      };

      hyperion = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          hostname = "hyperion";
        };
        modules = [
          ./hosts/common
          ./hosts/common/servers.nix
          ./hosts/hyperion
        ];
      };
    };

    packages.x86_64-linux.nvim = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      treesitterParsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
      };
    in
      pkgs.symlinkJoin {
        name = "nvim";
        buildInputs = [pkgs.makeWrapper];
        paths = [
          home/nvim
        ];
        postBuild = ''
          mkdir -p $out/bin $out/config/nvim $out/local/nvim/{nixpkgs,lazy}

          cat >$out/config/nvim/init.lua <<EOL
              local root = vim.fn.fnamemodify("/tmp/debugloop-nvim", ":p")
              for _, name in ipairs({ "data", "state", "cache" }) do
                vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
              end

              require("aucmd")
              require("options")
              require("maps")
              require("lsp")

              NIXPLUG_PATH = "$out" .. "/local/nvim/nixpkgs"

              local lazypath = NIXPLUG_PATH .. "/lazy-nvim"
              vim.opt.rtp:prepend(lazypath)

              require("lazy").setup({
                spec = {
                  { import = "plugins" },
                },
                defaults = {
                  lazy = true,
                },
                change_detection = {
                  enabled = false,
                },
                performance = {
                  rtp = {
                    disabled_plugins = {
                      "gzip",
                      "matchit",
                      "matchparen",
                      "netrwPlugin",
                      "tarPlugin",
                      "tohtml",
                      "tutor",
                      "zipPlugin",
                    },
                  },
                },
              })
              vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Manage plugins" })
          EOL

          # all other config
          cp -r $out/{lua,ftplugin,after} ${treesitterParsers}/parser $out/config/nvim/

          cp -r ${pkgs.vimPlugins.blink-cmp} $out/local/nvim/nixpkgs/blink-cmp
          cp -r ${pkgs.vimPlugins.conform-nvim} $out/local/nvim/nixpkgs/conform-nvim
          cp -r ${pkgs.vimPlugins.diffview-nvim} $out/local/nvim/nixpkgs/diffview-nvim
          cp -r ${pkgs.vimPlugins.friendly-snippets} $out/local/nvim/nixpkgs/friendly-snippets
          cp -r ${pkgs.vimPlugins.kanagawa-nvim} $out/local/nvim/nixpkgs/kanagawa-nvim
          cp -r ${pkgs.vimPlugins.kulala-nvim} $out/local/nvim/nixpkgs/kulala-nvim
          cp -r ${pkgs.vimPlugins.lazy-nvim} $out/local/nvim/nixpkgs/lazy-nvim
          cp -r ${pkgs.vimPlugins.lazydev-nvim} $out/local/nvim/nixpkgs/lazydev-nvim
          cp -r ${pkgs.vimPlugins.noice-nvim} $out/local/nvim/nixpkgs/noice-nvim
          cp -r ${pkgs.vimPlugins.nui-nvim} $out/local/nvim/nixpkgs/nui-nvim
          cp -r ${pkgs.vimPlugins.nvim-bqf} $out/local/nvim/nixpkgs/nvim-bqf
          cp -r ${pkgs.vimPlugins.nvim-dap} $out/local/nvim/nixpkgs/nvim-dap
          cp -r ${pkgs.vimPlugins.nvim-impairative} $out/local/nvim/nixpkgs/nvim-impairative
          cp -r ${pkgs.vimPlugins.nvim-lint} $out/local/nvim/nixpkgs/nvim-lint
          cp -r ${pkgs.vimPlugins.nvim-tree-lua} $out/local/nvim/nixpkgs/nvim-tree-lua
          cp -r ${pkgs.vimPlugins.nvim-treesitter} $out/local/nvim/nixpkgs/nvim-treesitter
          cp -r ${pkgs.vimPlugins.nvim-treesitter-context} $out/local/nvim/nixpkgs/nvim-treesitter-context
          cp -r ${pkgs.vimPlugins.nvim-treesitter-textobjects} $out/local/nvim/nixpkgs/nvim-treesitter-textobjects
          cp -r ${pkgs.vimPlugins.quicker-nvim} $out/local/nvim/nixpkgs/quicker-nvim
          cp -r ${pkgs.vimPlugins.render-markdown-nvim} $out/local/nvim/nixpkgs/render-markdown-nvim
          cp -r ${pkgs.vimPlugins.snacks-nvim} $out/local/nvim/nixpkgs/snacks-nvim

          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-ai
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-bracketed
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-bufremove
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-clue
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-diff
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-extra
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-files
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-git
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-hipatterns
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-icons
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-indentscope
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-jump
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-operators
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-pairs
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-pick
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-splitjoin
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-statusline
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-surround
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-tabline
          cp -r ${pkgs.vimPlugins.mini-nvim} $out/local/nvim/nixpkgs/mini-visits

          cp ${pkgs.neovim}/bin/nvim $out/bin/nvim
          wrapProgram $out/bin/nvim --set XDG_CONFIG_HOME $out/config
        '';
      };
  };
}
