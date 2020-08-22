export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

export ProjectPath="$HOME/Projects"

####################################
# set up aliases for project names #
####################################
set_project_varnames() {
  cd "$ProjectPath" &> /dev/null
  local dir
  local varname
  for dir in $(ls -d */ | tr -d /)
  do
    varname=$(echo $dir | tr [:lower:] [:upper:] | tr - _)

    if [ -z $(eval echo \$$varname) ]; then
        export $varname="$ProjectPath/$dir"
    fi
  done
  unset varname
  unset dir
  cd - &> /dev/null
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
    local __CWD="$PWD"
    local subdir

    if [[ $__CWD =~ ^$ProjectPath/ ]]
    then
      __CWD="${PWD#$ProjectPath/}"
      if [[ $__CWD =~ ([^/]+) ]]
      then
        subdir="${__CWD#${BASH_REMATCH[1]}}"
        __CWD="${BASH_REMATCH[1]}"

        if [ -z "$subdir" ]
        then
          subdir="/"
        fi
        __CWD="$__CWD,$subdir"
      fi
    else
      __CWD="${__CWD/$HOME/~}"
    fi
    echo -ne $__CWD
  }

  ##########################
  # branch name for prompt #
  ##########################
  get_git_prompt() {
    local output
    if [[ $PWD =~ ^$ProjectPath/ && $PWD != *"/.git"*  ]]
    then
      local br=$(get_git_branch)
      if [[ ! -z $br ]]
      then
        if [ "$br" == "develop" ] || [ "$br" == "master" ]
        then
          output="${output} $(tput setaf 160)$(tput setaf 0)"
        fi

        output="${output} $br"
      fi
    fi
    echo $output
  }

  #################
  # branch status #
  #################
  get_branch_status() {
    if [[ $PWD =~ ^$ProjectPath/ && $PWD != *"/.git"* ]]
    then
      git status | grep "nothing to commit" > /dev/null 2>&1
      if [ $? != 0 ]
      then
        echo "$(tput setaf 0)*"
      fi
    fi
  }

  ######################
  # connect PS1 pieces #
  ######################
  connect_prompt() {
    local colors=(0 70 220 214 208)
    local alt_colors=(0 0 227 0 0)
    local index=1

    local output
    for label in "$@"
    do
      if [ ! -z "$label" ]
      then
        IFS=',' read -a label_parts <<< "$label"
        if [ -z ${label_parts[1]} ]
        then
          output="${output}$(tput setab ${colors[${index}]})$(tput setaf ${colors[$[index-1]]})$(tput setaf 0) ${label_parts[0]} "
        else
          output="${output}$(tput setab ${alt_colors[${index}]})$(tput setaf ${colors[$[index-1]]})$(tput setaf 0) ${label_parts[0]} "
          output="${output}$(tput setab ${colors[${index}]})$(tput setaf ${alt_colors[$[index]]})$(tput setaf 0) ${label_parts[1]} "
        fi
        index=$[index+1]
      fi
    done
    output="${output}$(tput setab ${colors[0]})$(tput setaf ${colors[$[index-1]]})"
    echo $output$(tput sgr0)
  }

  ############################
  # setting the prompts here #
  ############################
  export PS1='\n\
$(connect_prompt "\D{%H:%M:%S}" "$(get_relative_path)" "$(get_git_prompt)" "$(get_branch_status)")\n\
\[$(tput sgr0)\]\[$(tput setaf 1)\]∮\[$(tput sgr0)\] '

  export PS2='\[$(tput setaf 1)\] ∯\[$(tput sgr0)\] '
}
set_prompt

########################
# find git branch name #
########################
get_git_branch() {
   git rev-parse --abbrev-ref HEAD 2> /dev/null
}

###########
# aliases #
###########
alias ls="ls -GFh"
alias ll="ls -ogha"
alias grep="grep --color"
alias chrome-no-cors="open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security"

clone-fork() {
  origin=$1
  [[ $origin =~ (.+):.+/(.+) ]]
  fork="${BASH_REMATCH[1]}:username/${BASH_REMATCH[2]}"
  path=${BASH_REMATCH[2]%.git}
  git clone $fork &&
  cd $path &&
  git remote add upstream $1 &&
  git remote -v
}

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
