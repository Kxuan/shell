#!/bin/bash

[[ $- != *i* ]] && return
#PS1='[\u@\h \W]\$ '
export PATH="$PATH:$HOME/bin"
# Unlimit bash history size
HISTSIZE=-1
# remove spaces from bash history
HISTCONTROL=ignorespace
# apply history immediately
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
# add some other useful path to bash cd command
# Use vim as default text editor
export EDITOR='/usr/bin/vim'
export VISUAL='/usr/bin/vim'

__bash_load_helpers() {
    local i
    for i in ~/bin/helper/*.sh; do
        if [[ -x $i ]]; then
            . $i
        fi
    done
}
__bash_load_helpers
unset __bash_load_helpers

alias sudo='sudo '
alias ..='cd ..'
alias make='make -j4'
alias open='gnome-open'
alias vi=vim
alias grep='grep --color=auto --binary-files=without-match -I -D skip'
alias less='less -r'
alias dd='dd status=progress'
alias grp='grep -nrP'
alias wget='wget --content-disposition'
alias xfreerdp='xfreerdp +clipboard /drive:home,$HOME /admin '
alias hd='hexdump -C'
alias cp='cp --reflink=auto -v'
alias mv='mv -v'
alias l='ls -Alh'
alias ls='ls --color=auto'
alias rm='rm --verbose'
alias pkill='pkill -c'
alias virt-manager='virt-manager --spice-disable-auto-usbredir'
alias axel='axel -a -n10'
alias takeowner='sudo chown $USER:$GROUPS'

#Intelligent error correction
alias ks='ls'
alias xs='cd'
alias sl='ls'

#
markdir_setup_alias g back markhere || echo "markhere alias fail"

#resize window size after each child process exit 
trap 'builtin kill -WINCH $$' SIGCHLD


# GoLang environment
export GOPATH='/data/sources/gopath/'
