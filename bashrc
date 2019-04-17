REPO_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd )

# Disables history expansion (so I can put exclamation marks in double-quoted 
# commit messages without bash complaining all over me. Pfft, LIKE I CARE, BASH!)
set +H


###########
# HISTORY #
###########

# Append to .bash_history on session close, instead of overwriting
shopt -s histappend

# Essentially disable history file truncation
export HISTFILESIZE=1000000
export HISTSIZE=1000000

# Store full date and time for each history line
export HISTTIMEFORMAT='%F %T '

# Condense multi-line commands to one line
shopt -s cmdhist

# Ignore duplicate commands
export HISTCONTROL="ignoredups"



############
# VIM MODE #
############
# vim bindings, yeah!
set -o vi
# Fix Ctrl-L to clear the screen
bind '\C-l:clear-screen'
# Fix Ctrl-LeftArrow and Ctrl-RightArrow to move words
bind '"\e[1;5C":forward-word'
bind '"\e[1;5D":backward-word'
# TODO: fix Ctrl+Backspace and Ctrl+Delete to delete words

# Fix Ctrl-A and Ctrl-E
bind '\C-a:beginning-of-line'
bind '\C-e:end-of-line'


#####
# Z #
#####
# Setup z (https://github.com/theY4Kman/z -- using my own version, which also prints
#          the dir being cd'd to, so it can be used like so: pushd `z mydir`)
Z_PATH="${REPO_DIR}/z/z.sh"
if [ -e "$Z_PATH" ]; then
    source "$Z_PATH"
fi
# YOU DON'T KNOW WHO MY SYMLINKS REALLY ARE
export _Z_NO_RESOLVE_SYMLINKS=true


#########################
# CONVENIENCE FUNCTIONS #
#########################

# Convenience function for pushd `z ...`
function pushz() {
    cd=`z $*`
    [ "$cd" ] && pushd "$cd"
}
# Some symmetry
alias popz=popd


# Convenience function to make a directory and cd to it
function mkcd() {
    mkdir -p "$1" && cd "$1"
}


# Make a new virtualenv with the name of the current directory.
# Also sets the virtualenv project
function mkvirtualenvhere() {
    mkvirtualenv -a . "$(basename "$(pwd)")" "$@"
}



###########
# ALIASES #
###########

# general
alias grep="grep --color=auto -i"
alias xargs="xargs -L1"  # why this isn't default, idfk

# lazy
alias ..='cd ..'
alias l='ls'
alias ll='ls -l'
alias lla='ls -la'
alias la='ls -la'  # come on, i don't really ever want just `ls -a`

# Package management
alias sai="sudo apt-get install"
alias syi="sudo yum install"

# git-related
alias gs="git status"
alias gl="git log"
alias gm="git checkout master"
alias gd="git diff"
alias gdc="git diff --cached"
alias gaa="git add --all"
alias gmm="git merge master"
alias gfa="git fetch --all"
alias gfap="git fetch --all --prune"
alias gfapr="git fetch --all --prune && git rebase"
alias gr="git rebase"
alias gorm="git rebase origin/master"
alias grm="git rebase master"

# python
alias pipfile="pipenv"  # sue me

# Picked up from Dan @ StyleSeat
alias pmp="python manage.py"
alias pmps="pmp shell"
alias pmpsp="pmp shell_plus"
alias pmpdb="pmp dbshell"
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
alias amke="make"

alias got="git"
alias gut="git"
alias guit="git"
alias goit="git"
alias giot="git"

alias pyhton="python"
alias pyhton2="python2"
alias "pyhton2.5"="python2.5"
alias "pyhton2.6"="python2.6"
alias "pyhton2.7"="python2.7"
alias pyhton3="python3"
alias "pyhton3.5"="python3.5"
alias "pyhton3.6"="python3.6"

alias nom="npm"
alias npom="npm"
alias nopm="npm"


###########
# EXPORTS #
###########
# Add my scripts under bin/ to the $PATH
export PATH="$PATH:$REPO_DIR/bin"

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


################
# AUTOCOMPLETE #
################

# Enable Django manage.py bash completion
. "${REPO_DIR}/django_bash_completion.sh"


# Enable bash completion for aliases (magic!)
#. "${REPO_DIR}/bash_alias_completion.sh"


_complete_ssh_hosts ()
{
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
                        cut -f 1 -d ' ' | \
                        sed -e s/,.*//g | \
                        grep -v ^# | \
                        uniq | \
                        grep -v "\[" ;
                cat ~/.ssh/config | \
                        grep "^Host " | \
                        awk '{print $2}'
                `
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}

# By default, OSX doesn't autocomplete hosts in .ssh/config
if [[ "$OSTYPE" == "darwin"* ]]; then
    complete -F _complete_ssh_hosts ssh
fi



###############
# PS1 HELPERS #
###############

# Displays the current activated virtualenv
__venv_ps1 ()
{
    if [ -n "${VIRTUAL_ENV}" ]; then
        if [ -z "${PYTHON_VERSION+x}" ]; then
            PYTHON_VERSION="$(python -V 2>&1 | awk '{print $NF}')"
        fi
        echo [${VIRTUAL_ENV##*[/\\]}${PYTHON_VERSION:+" :: $PYTHON_VERSION"}]
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

# Windows Bash has some trouble printing newlines after function calls
# inside an `echo -e`. So, we output some newlines as the ASCII code \012
# Ref: https://stackoverflow.com/a/37074809

ps1_user() {
    user="${USER:-${USERNAME}}"

    # If user is root, display the username in red
    if [ "$USER" = "root" ]; then
        color='\e[0;31m'
    else
        color='\e[0;36m'
    fi

    echo -e ${color}${user}'\e[m'
}

ps1_line1='# \[\e[0;31m\]\#\[\e[m\] \[\e[1;32m\]\t\[\e[m\] \[\e[0;32m\]\D{%Y/%m/%d}\[\e[m\] `ps1_user`\[\e[90m\]@${HOSTNAME:=$(hostname)}$([ -z "$HIDE_HOSTNAME_WARNING" ] && echo -e " \[\e[41m\e[97m\][!]")\[\e[m\]'
ps1_line2='# \[\e[1;33m\]\w\[\e[m\]'
ps1_line3='#\[\e[0;35m\]$(__git_ps1)$(svn_branch)\[\e[m\] \[\e[0;33m\]$(__venv_ps1)\[\e[m\]\012`echo \# > /tmp/.$$.cmdnum`'

if [[ "$OSTYPE" == "darwin"* ]]; then
    ps1_marker='\[$(iterm2_prompt_mark)\]'
else
    ps1_marker=''
fi

export PS1="\012${ps1_line1}\012${ps1_line2}\012${ps1_line3}${ps1_marker}"


###########
# CLEANUP #
###########

clean_ps1_cmdnum_file() {
    rm -f /tmp/.$$.cmdnum 2>/dev/null;
}


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
#   # 17 19:12:55 2013/09/13 #! ls --color=auto -A ~
#   # 17 19:12:55 2013/09/13 #! grep --color=auto -i yo
#
# Benefits
#
#  - After Enter is hit at prompt, a line is printed with the date and time
#    When the command completes, the PS1 will be printed with date and time,
#    Allowing the measurement of how long a command takes
#
#  - Each #! line prints the command executed in expanded form,
#    revealing what's actually being run behind aliases and the such.
#
#
# Downsides
#
#  - A line is printed for every command in a pipeline, which can lead to many
#    START lines. (Again, I'd rather have more information than less.
#    After all, what is infinite scrollback for, anyway?)
#

###
# Characters to display after date and time in start line
#
YAK_START_SYMBOL='::'


preexec_invoke_exec () {
    ###
    # do nothing if completing
    #
    [ -n "$COMP_LINE" ] && return

    ###
    # allow manual omission of START line
    #  (including start-of-line env var cases, e.g. `DISABLE_START_LINE=true echo hi`)
    #
    if [ -n "$DISABLE_START_LINE" ] || [[ "$BASH_COMMAND" == DISABLE_START_LINE=* ]]; then
        return
    fi

    ###
    # if no command is being executed (idk how), ignore it
    #
    [[ -z "$BASH_COMMAND" ]] && return;

    ###
	# don't print anything for the prompt command
    #
    [ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return

    ###
    # ignore z (the weighting chdir command) performing its calculations
    #
    [[ "$BASH_COMMAND" == _z* ]] && return;

    ###
    # ignore hooks from direnv (the per-directory .env file sourcer)
    #
    [[ "$BASH_COMMAND" == _direnv_hook* ]] && return;

    ###
    # Print the start line
    #
    echo -e '# \x1B[0;31m'`cat /tmp/.$$.cmdnum 2>/dev/null || echo 1`'\x1B[m' '\x1B[1;32m'`date +%T` '\x1B[0;32m'`date +'%Y/%m/%d'`'\x1B[m '$YAK_START_SYMBOL' \x1B[0;34m'$BASH_COMMAND'\x1B[m'
}


trap 'clean_ps1_cmdnum_file' EXIT;
trap 'preexec_invoke_exec' DEBUG


# Load all history from historian
# Performed down here, so commands run in our .bashrc don't get recorded
# https://github.com/jcsalterego/historian
DISABLE_START_LINE=true "${REPO_DIR}/bin/hist" import > /dev/null
