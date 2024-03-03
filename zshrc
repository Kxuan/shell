# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=9999999
SAVEHIST=20000000
setopt autocd extendedglob notify
unsetopt nomatch
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/xuan//.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/lib/python3.11/site-packages/powerline/bindings/zsh/powerline.zsh

alias ls='ls --color=auto'
alias grep='grep --color=auto'

export http_proxy=http://10.0.1.5:8118
export https_proxy=http://10.0.1.5:8118
export no_proxy='127.0.0.0/8,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,localhost,.local,.kx'
