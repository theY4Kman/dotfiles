REPO_DIR=$( cd $(dirname "${BASH_SOURCE[0]}") ; pwd )

# Disables history expansion (so I can put exclamation marks in double-quoted 
# commit messages without bash complaining all over me. Pfft, LIKE I CARE, BASH!)
set +H


###########
# HISTORY #
###########

# Append to .bash_history on session close, instead of overwriting
shopt -s histappend

# Essentially disable history file truncation
HISTFILESIZE=1000000
HISTSIZE=1000000

# Store full date and time for each history line
HISTTIMEFORMAT='%F %T '

# Condense multi-line commands to one line
shopt -s cmdhist

# Load all history from historian
# https://github.com/jcsalterego/historian
${REPO_DIR}/bin/hist import > /dev/null


############
# VIM MODE #
############
# vim bindings, yeah!
set -o vi
# Fix Ctrl-A and Ctrl-E
bind '\C-a:beginning-of-line'
bind '\C-e:end-of-line'


#####
# Z #
#####
# Setup z (https://github.com/theY4Kman/z -- using my own version, which also prints
#          the dir being cd'd to, so it can be used like so: pushd `z mydir`)
Z_PATH=${REPO_DIR}/z/z.sh
if [ -e $Z_PATH ]; then
    source $Z_PATH
fi
# YOU DON'T KNOW WHO MY SYMLINKS REALLY ARE
export _Z_NO_RESOLVE_SYMLINKS=true


#########################
# CONVENIENCE FUNCTIONS #
#########################

# Convenience function for pushd `z ...`
function pushz() {
    cd=`z $*`
    [ "$cd" ] && pushd $cd
}
# Some symmetry
alias popz=popd


# Convenience function to make a directory and cd to it
function mkcd() {
    mkdir -p $1 && cd $1
}


# Make a new virtualenv with the name of the current directory.
# Also sets the virtualenv project
function mkvirtualenvhere() {
    mkvirtualenv -a . $(basename "$(pwd)") "$@"
}



###########
# ALIASES #
###########

# general
alias grep="grep --color=auto -i"
alias xargs="xargs -L1"  # why this isn't default, idfk

# Package management
alias sai="sudo apt-get install"
alias syi="sudo yum install"

# git-related
alias gs="git status"
alias gm="git checkout master"
alias gd="git diff"
alias gdc="git diff --cached"
alias gaa="git add --all"
alias gmm="git merge master"
alias gfa="git fetch --all"

# Picked up from Dan @ StyleSeat
alias pmp="python manage.py"
# Matching hivelocity
alias djp="django-admin.py"

# terraform, thx keene
alias tf=terraform
alias terraform-graph='dot -Tpng <(terraform graph) | open -a Preview.app -f'
alias tf-graph=terraform-graph


#################
# DRUNK ALIASES #
#################

alias sssh="ssh"
alias got="git"


###########
# EXPORTS #
###########
# Add my scripts under bin/ to the $PATH
export PATH=$PATH:$REPO_DIR/bin

# Select vim if it exists, fallback to vi
export EDITOR=`hash vim 2>/dev/null && echo vim || echo vi`

# Show an asterisk by git branch if working directory is dirty/has changes
export GIT_PS1_SHOWDIRTYSTATE=true
# We override the default venv display, so disable it
export VIRTUAL_ENV_DISABLE_PROMPT=true


# I've seen the PROMPT_COMMAND get filled when root, and it ends up printing many
# unnecessary lines, and I don't want that clutter. The command in particular
# (printf "" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}") doesn't seem to print
# anything, anyways. So, if we're root, I'm going to clear PROMPT_COMMAND
if [[ $EUID == 0 ]] && [[ $PROMPT_COMMAND == printf* ]]; then
    export PROMPT_COMMAND=""
fi




###############
# PS1 HELPERS #
###############

# Displays the current activated virtualenv
__venv_ps1 ()
{
    if [ -n "${VIRTUAL_ENV}" ]; then
        echo [${VIRTUAL_ENV##*/}]
    fi
}

function svn_branch
{
  if [ ! -d .svn ]; then
    exit 1
  fi
 
  # Get the current URL of the SVN repo
  URL=`svn info --xml | fgrep "<url>"`
 
  # Strip the tags
  URL=${URL/<url>/}
  URL=${URL/<\/url>/}
 
  # Find the branches directory
  if [[ "$URL" == */trunk ]]; then
    DIR=${URL//\/trunk*/}
  fi
  if [[ "$URL" == */tags/* ]]; then
    DIR=${URL//\/tags*/}
  fi
  if [[ "$URL" == */branches/* ]]; then
    DIR=${URL//\/branches*\/*/}
  fi
  DIR="$DIR/branches"
 
  # Return the branch name
  if [[ "$URL" == */trunk* ]]; then
    echo ' (trunk)'
  elif [[ "$URL" == */branches/* ]]; then
    echo $URL | sed -e 's#^'"$DIR/"'##g' | sed -e 's#/.*$##g' | awk '{print " ("$1")" }'
  fi
}

# Get __git_ps1 if we don't have it
command -v __git_ps1 >/dev/null 2>&1
if [ $? != 0 ]; then
  SCRIPT_PATH=${REPO_DIR}/git-prompt.sh
  if [ ! -e $SCRIPT_PATH ]; then
    wget https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh -O $SCRIPT_PATH
  fi
  source $SCRIPT_PATH
fi


# Enable Django manage.py bash completion
. ${REPO_DIR}/django_bash_completion.sh


# Enable bash completion for aliases (magic!)
. ${REPO_DIR}/bash_alias_completion.sh


#############
# YAK'S PS1 #
#############
#
# Looks like:
#
#   # 17 18:47:23 2013/05/23 user@hostname
#   # ~/programming/code-tests
#   # (vcs-branch *) [myvirtualenv]
#
#
# Benefits:
#
#  - Each line begins with a hash, so scrollback can be copied and executed
#  - Command input is on its own line, so it doesn't wrap when writing commands
#    Fringe benefit: commands can be selected with a triple-click
#  - Colors visually contrast from command output
#
#
# Downsides:
#
#  - SO MANY LINES, ALWAYS PRINTING, AHHHHHHHHHH-ee couldn't give a shit.
#

ps1_line1='# \e[0;31m\#\e[m \e[1;32m\t\e[m \e[0;32m\D{%Y/%m/%d}\e[m \e[36m$USER\e[90m@$HOSTNAME\e[m'
ps1_line2='# \e[1;33m\w\e[m'
ps1_line3='#\e[0;35m$(__git_ps1)$(svn_branch)\e[m \e[0;33m$(__venv_ps1)\e[m\n`echo \# > /tmp/.$$.cmdnum`'

export PS1="\n${ps1_line1}\n${ps1_line2}\n${ps1_line3}"


###########
# CLEANUP #
###########

clean_ps1_cmdnum_file() {
    rm -f /tmp/.$$.cmdnum 2>/dev/null;
}
trap 'clean_ps1_cmdnum_file' EXIT;


##############
# START LINE #
##############
#
# Looks like:
#
#   # 17 18:47:23 2013/05/23 user@hostname
#   # ~/programming/code-tests
#   # (vcs-branch *) [myvirtualenv]
#   la ~ | grep yo
#   # 17 19:12:55 2013/09/13 ####### START ###### ls --color=auto -A ~
#   # 17 19:12:55 2013/09/13 ####### START ###### grep --color=auto -i yo
#
# Benefits
#
#  - After Enter is hit at prompt, a line is printed with the date and time
#    When the command completes, the PS1 will be printed with date and time,
#    Allowing the measurement of how long a command takes
#
#  - Each ### START ### line prints the command executed in expanded form,
#    revealing what's actually being run behind aliases and the such.
#
#
# Downsides
#
#  - A line is printed for every command in a pipeline, which can lead to many
#    START lines. (Again, I'd rather have more information than less.
#    After all, what is infinite scrollback for, anyway?)
#

preexec_invoke_exec () {
    [ -n "$COMP_LINE" ] && return  # do nothing if completing
    # The _z is for z, the weighting chdir db command.
    # Really, I should be testing for $PROMPT_COMMAND, because that's what the first test is for. Otherwise, the echo is run twice every Enter.
    if [[ "$BASH_COMMAND" == _z* ]] || [[ -z "$BASH_COMMAND" ]]; then
        return
    fi
    echo -e '# \e[0;31m'`cat /tmp/.$$.cmdnum 2>/dev/null || echo 1`'\e[m' '\e[1;32m'`date +%T` '\e[0;32m'`date +'%Y/%m/%d'`'\e[m ####### START ###### \e[0;34m '$BASH_COMMAND'\e[m'
}
trap 'preexec_invoke_exec' DEBUG

