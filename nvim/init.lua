-- ==========================================
--
-- 1. 基础设置
-- ==========================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "

-- 缩进设置 (2个空格)
vim.opt.tabstop = 2        -- 按下 Tab 键时代表的空格数
vim.opt.shiftwidth = 2     -- 自动缩进时的空格数 (>> 操作)
vim.opt.softtabstop = 2    -- 编辑模式下按退格键一次删除 2 个空格
vim.opt.expandtab = true   -- 将 Tab 键自动转换为空格 (禁止 \t 字符)

-- ==========================================
-- 2. 插件管理器 (Lazy.nvim)
-- ==========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================
-- 3. 插件清单
-- ==========================================
require("lazy").setup({
  -- [文件管理] Oil
  {
    'stevearc/oil.nvim',
    opts = {},
    config = function()
      require("oil").setup({ view_options = { show_hidden = true } })
      vim.keymap.set("n", "-", "<CMD>Oil<CR>")
    end
  },

  -- [UI美化] 让 vim.ui.select 变成弹窗
  {
    "stevearc/dressing.nvim",
    opts = {},
  },

  -- [高亮核心] Treesitter (带容错保护版)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- 安装后自动更新 Parser
    event = { "BufReadPost", "BufNewFile" }, -- 懒加载：打开文件后再加载，防止启动卡死
    config = function() 
      -- 使用 pcall 尝试加载，如果失败则静默退出，不弹红框报错
      local status, configs = pcall(require, "nvim-treesitter.configs")
      if not status then return end

      configs.setup({
        -- 只安装最基础的，减少下载失败概率
        ensure_installed = { "vim", "lua", "markdown", "markdown_inline", "bash" },
        
        -- 自动安装缺失的 Parser (建议开启，需要网络好)
        auto_install = true,

        highlight = {
          enable = true,
          -- 对大文件禁用 treesitter 以防卡顿
          disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                  return true
              end
          end,
        },
      })
    end
  },

  {
    "Mofiqul/dracula.nvim",
    lazy = false,    -- 启动时立即加载
    priority = 1000, -- 确保在其他插件之前加载
    config = function()
      local dracula = require("dracula")
      dracula.setup({
        -- 开启透明背景
        transparent_bg = true, 
        -- 让注释显示为斜体 (Dracula 特色)
        italic_comment = true, 
        -- 其它偏好
        show_end_of_buffer = true, 
      })
      -- 设定当前主题
      vim.cmd([[colorscheme dracula]])
    end,
  },

  -- [状态栏] Lualine (Airline 的现代替代品)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- 需要安装 Nerd Font 字体才有图标
    config = function()
      require('lualine').setup({
        options = {
          theme = 'dracula', -- 直接适配你的主题
          -- 下面是经典的 Airline 风格三角形分隔符
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
          
          -- 如果你想要那种圆角气泡风格 (如果不喜欢可以删掉下面两行)
          -- component_separators = '|',
          -- section_separators = { left = '', right = '' },
        },
        sections = {
          -- 优化显示：只显示文件名，不显示冗长的路径，保持简约
          lualine_c = {{'filename', path = 1}}, 
        }
      })
    end
  },

})

-- ==========================================
-- 4. 快捷键
-- ==========================================
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- 打开 .config 目录，用 Oil 浏览所有软件的配置
vim.keymap.set("n", "<leader>ec", ":Oil ~/.config<CR>", { desc = "Browse .config" })

-- <leader>sv = Source Vimrc (重载配置)
vim.keymap.set("n", "<leader>sv", function()
    vim.cmd("source $MYVIMRC")
    print("配置已重载！")
end, { desc = "Reload Config" })

-- ==========================================
-- 5. 极速配置文件菜单 (最终稳定版)
-- ==========================================
vim.keymap.set("n", "<leader>c", function()
  -- 定义菜单项 (Key = { Path, Description })
  local items = {
    v = { path = "~/.config/nvim/init.lua",      desc = "Neovim" },
    z = { path = "~/.zshrc",                     desc = "Zsh" },
    t = { path = "~/.tmux.conf",                 desc = "Tmux" },
    g = { path = "~/.config/ghostty/config",     desc = "Ghostty" },
  }

  -- 1. 显示简易菜单 (告诉你要按什么)
  print("⚡️ Configs: [v]Vim [z]Zsh [t]Tmux [g]Ghostty")

  -- 2. 获取按键并转为小写 (确保 g 和 G 都能触发)
  local char = vim.fn.nr2char(vim.fn.getchar()):lower()

  -- 3. 清除命令行提示
  vim.cmd("redraw")

  -- 4. 查找并跳转
  local target = items[char]
  
  if target then
    local file = vim.fn.expand(target.path) -- 把 ~ 展开为 /Users/xxx
    if vim.fn.filereadable(file) == 1 then
      vim.cmd("edit " .. file)
      print("✅ Editing: " .. target.desc)
    else
      -- 如果文件不存在，用红色报错提示路径
      vim.api.nvim_echo({{ "❌ 文件未找到: " .. file, "ErrorMsg" }}, true, {})
    end
  elseif char == "q" or char == "\27" then
    print("已取消")
  else
    print("⚠️  无效按键")
  end
end, { desc = "Fast Config Menu" })
