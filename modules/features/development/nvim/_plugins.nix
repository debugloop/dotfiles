{pkgs}: [
  pkgs.vimPlugins.blink-cmp
  pkgs.vimPlugins.codediff-nvim
  (pkgs.vimUtils.buildVimPlugin {
    pname = "opencode-nvim";
    version = "0.10.0";
    src = pkgs.fetchFromGitHub {
      owner = "nickjvandyke";
      repo = "opencode.nvim";
      rev = "v0.10.0";
      sha256 = "0yd20qccqd8n6p0pf0q968whgj749ls9rqxm6ccgkaax9kxrvvqz";
    };
    postPatch = ''
      substituteInPlace lua/opencode/server/init.lua \
        --replace-fail 'vim.schedule_wrap(self.disconnect)' \
                       'vim.schedule_wrap(function() self:disconnect() end)'
    '';
  })
  pkgs.vimPlugins.conform-nvim
  pkgs.vimPlugins.friendly-snippets
  pkgs.vimPlugins.kanagawa-nvim
  pkgs.vimPlugins.lazydev-nvim
  pkgs.vimPlugins.mini-nvim
  pkgs.vimPlugins.nvim-dap
  pkgs.vimPlugins.nvim-dap-view
  pkgs.vimPlugins.nvim-lint
  pkgs.vimPlugins.nvim-spider
  (pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-tree-pairs";
    version = "git";
    src = pkgs.fetchFromGitHub {
      owner = "yorickpeterse";
      repo = "nvim-tree-pairs";
      rev = "1370b02f62ac49be5c709474520f8f86c7a3504f";
      sha256 = "17bbgng7b4fc6w2ii1m8l8qww8iipmirlq7skx3192wbcsdjdaf0";
    };
  })
  pkgs.vimPlugins.nvim-treesitter-textobjects
  pkgs.vimPlugins.snacks-nvim
  (pkgs.vimUtils.buildVimPlugin {
    pname = "layers-nvim";
    version = "git";
    src = pkgs.fetchFromGitHub {
      owner = "debugloop";
      repo = "layers.nvim";
      rev = "ebbb386d7aea84a04bf7eab0873975b2e9d695a5";
      sha256 = "0qam0a6h34hf8syw9yv936yilf6ib7cppkbk9wx74n030yna72k0";
    };
  })
]
