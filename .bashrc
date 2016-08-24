#!/bin/bash

[[ $- != *i* ]] && return
alias ..='cd ..'
alias make='make -j4'
alias open='gnome-open'
alias vi=vim
alias grep='grep --color=auto --binary-files=without-match -I -D skip'
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
alias ks='ls'
alias xs='cd'
alias sl='ls'
alias pkill='pkill -c'
alias virt-manager='virt-manager --spice-disable-auto-usbredir'

#PS1='[\u@\h \W]\$ '

# Unlimit bash history size
HISTSIZE=-1
# remove spaces from bash history
HISTCONTROL=ignorespace
# apply history immediately
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
# add some other useful path to bash cd command
# Use vim as default text editor
EDITOR='/usr/bin/vim'

__include_functions() {
    for i in ~/bin/helper/*.sh; do
        if [[ -x $i ]]; then
            . $i
        fi
    done
}
__include_functions
unset __include_functions

