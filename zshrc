HISTFILE=~/.histfile
HISTSIZE=9999999
SAVEHIST=99999999
setopt appendhistory autocd notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/xuan/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
alias pacman='pacman --color=auto'
alias yay='yay --color=auto'

powerline-daemon -q
. /usr/lib/python3.7/site-packages/powerline/bindings/zsh/powerline.zsh
alias ls='ls --color=auto'
alias grep='grep --color=auto'
export EDITOR=vim
