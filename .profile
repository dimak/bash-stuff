PATH=/usr/local/bin:$PATH
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
PATH=$PATH:/opt/local/bin:/opt/local/sbin

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

export ProjectPath="$HOME/Projects"

####################################
# set up aliases for project names #
####################################
set_project_varnames() {
    cd $ProjectPath
    local dir
    local varname
    for dir in $(ls -d */ | tr -d /)
    do
        varname=$(echo $dir | tr [:lower:] [:upper:] | tr - _)

        if [ -z $(eval echo \$$varname) ]; then
            export $varname="$ProjectPath/$dir"
            # echo "\$$varname -> $ProjectPath/$dir"
            # else
            # echo "$varname is taken; not set"
        fi
    done
    unset varname
    unset dir
    cd -
}
set_project_varnames

################
# set PS1, PS2 #
################
set_prompt() {
    #################################################
    # get path relative to $ProjectPath, $HOME, etc #
    #################################################
    get_relative_path() {
        local __CWD=$PWD
        if [[ $__CWD =~ ^$ProjectPath/ ]]
        then __CWD=${PWD#$ProjectPath/}
            if [[ $__CWD =~ ([^/]+) ]]
            then echo -ne "$(tput bold)$(tput setaf 3)${BASH_REMATCH[1]}$(tput sgr0)"
                __CWD=${__CWD#${BASH_REMATCH[1]}}
             fi
        fi
        echo -ne "$(tput setaf 3)${__CWD/$HOME/~}"
        unset __CWD
    }

    ###########################
    # colorize branch for PS1 #
    ###########################
    get_git_prompt() {
        local output
        if [[ $PWD =~ ^$ProjectPath/ ]]
        then
            output="$(tput setaf 6)[$(get_git_branch)]$(tput sgr0)"
            echo $(git status) | grep "nothing to commit" > /dev/null 2>&1
            if [ $? != 0 ]
            then
                output="${output}$(tput setaf 1)$(tput bold)*"
            fi
            output="${output}$(tput sgr0)"
        fi
        echo $output
    }

    export PS1='\n\
\[$(tput setaf 1)\]╓\[$(tput setaf 2)\] \D{%H:%M:%S}\[$(tput sgr0)\] $(get_relative_path) $(get_git_prompt)\n\
\[$(tput setaf 1)\]╙\[$(tput sgr0)\] ';
    export PS2='\[$(tput setaf 1)\]  ┕\[$(tput sgr0)\]  '
}
set_prompt

########################
# find git branch name #
########################
get_git_branch() {
   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}


###########
# aliases #
###########
alias ls="ls -GFh"
alias ll="ls -la"
alias startserv="bundle exec rails server"
alias cuke="bundle exec cucumber"

#############################
# git aliases and functions #
#############################

alias gCherry="git cherry -v develop | sed -e \"s/+ \([^ ]*\) \(.*\)/* $(tput setaf 2)\1 $(tput sgr0)\2/\""
alias gDiffTree="git diff-tree --no-commit-id --name-only -r"

gPush() {
    git push -v --porcelain origin $(get_git_branch) 2> /dev/null | sed -e "s/^\(.\)    refs\/heads\/\([^   ]*\):refs\/heads\/\([^  ]*\)    *\(.*\)$/\1 $(tput setaf 3)\2 -> \3$(tput sgr0) \4/"
}