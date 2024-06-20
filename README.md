# my conf file
```sh
sudo ln -s /Applications/MacVim.app/Contents/bin/mvim /usr/local/bin/mvim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


# 安装字体
brew install font-hack-nerd-font --cask

git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
# 字体安装完成了，记得在 iterm2 里面设置字体 Hack Nerd font

```
Copy vimrc to .vimrc

:PlugInstall

