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
bind '"\e[1;5C":forward-word'   # ctrl-rightarrow
bind '"\e[1;5D":backward-word'  # ctrl-leftarrow

# Fix Ctrl+Backspace and Ctrl+Delete to delete words
bind '"\e[3;5~": kill-word'     # ctrl-delete
bind '"\b":backward-kill-word'  # ctrl-backspace (idk why \b works. ref: https://superuser.com/a/245254)

# Fix Ctrl-K to delete text from cursor to end of line
bind '"\C-k":kill-line'
# Fix Ctrl-U to delete text from cursor to beginning of line
bind '"\C-u":backward-kill-line'

# Fix Ctrl-A and Ctrl-E
bind '\C-a:beginning-of-line'
bind '\C-e:end-of-line'


####################
# ALIAS COMPLETION #
####################
# Setup cykerway/complete-alias, which lets us perform bash completions
# on arbitrary aliases (with or without trailing arguments!)
# See https://github.com/cykerway/complete-alias
#
COMPLETE_ALIAS_PATH="${REPO_DIR}/complete-alias/complete_alias"
if [ -e "$COMPLETE_ALIAS_PATH" ]; then
    . "$COMPLETE_ALIAS_PATH"
    _YAK_HAS_COMPLETE_ALIAS=true
fi

function _add_alias() {
    if [ -n "$_YAK_HAS_COMPLETE_ALIAS" ]; then
        for name in "$@"; do
            complete -F _complete_alias "$name"
        done
    fi
}


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


#########################
# GIT/HUB FUNCTIONALITY #
#########################

# The default branch to use with the `gm` alias (and others)
YAK_GIT_DEFAULT_BRANCH='master'

###
# Convenience method to pull the default branch of a repo from GitHub
#
#  It will use the GitHub owner/repo from the git repo in $PWD by default,
#  but other values may be passed as `_github_get_default_branch "owner" "repo"`
#
function _github_get_default_branch() {
    OWNER="${1:-"{owner}"}"
    REPO="${2:-"{repo}"}"

    if command -v hub &> /dev/null; then
        hub api "/repos/$OWNER/$REPO" | jq .default_branch -r
    fi
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
_add_alias l ll lla la

# human-readable defaults
alias ls='ls --color=auto -h'

# sudo
alias sudoi='sudo -i'
_add_alias sudoi

# Package management
alias sai="sudo apt-get install"
alias syi="sudo yum install"
_add_alias sai syi

# git-related
alias gs="git status"
alias gl="git log"
function gm() { git checkout "${YAK_GIT_DEFAULT_BRANCH:master}"; }
alias gd="git diff"
alias gdc="git diff --cached"
alias gaa="git add --all"
function gmm() { git merge "${YAK_GIT_DEFAULT_BRANCH}"; }
alias gfa="git fetch --all"
alias gfap="git fetch --all --prune"
alias gfapr="git fetch --all --prune && git rebase"
alias gr="git rebase"
function gorm() { git rebase "origin/${YAK_GIT_DEFAULT_BRANCH}"; }
function grm() { git rebase "${YAK_GIT_DEFAULT_BRANCH}"; }
_add_alias gs gl gd gdc gaa gfa gfap gfapr gr

# python
alias pipfile="pipenv"  # sue me

# Picked up from Dan @ StyleSeat
alias pmp="python manage.py"
alias pmps="pmp shell"
alias pmpsp="pmp shell_plus"
alias pmpdb="pmp dbshell"
# Matching hivelocity
alias djp="django-admin.py"
_add_alias pmp pmps pmpsp pmpdb djp

# terraform, thx keene
alias tf=terraform
alias terraform-graph='dot -Tpng <(terraform graph) | open -a Preview.app -f'
alias tf-graph=terraform-graph
_add_alias tf terraform-graph tf-graph


#################
# DRUNK ALIASES #
#################

alias sssh="ssh"
alias amke="make"
_add_alias sssh amke

alias got="git"
alias gut="git"
alias guit="git"
alias goit="git"
alias giot="git"
_add_alias got gut guit goit giot

alias pyhton="python"
alias pyhton2="python2"
alias "pyhton2.5"="python2.5"
alias "pyhton2.6"="python2.6"
alias "pyhton2.7"="python2.7"
alias pyhton3="python3"
alias "pyhton3.5"="python3.5"
alias "pyhton3.6"="python3.6"
alias "pyhton3.7"="python3.7"
alias "pyhton3.8"="python3.8"
alias "pyhton3.9"="python3.9"
alias "pyhton3.10"="python3.10"
_add_alias pyhton pyhton2 pyhton2.5 pyhton2.6 pyhton2.7 pyhton3 pyhton3.5 \
    pyhton3.6 pyhton3.7 pyhton3.8 pyhton3.9 pyhton3.10

alias nom="npm"
alias npom="npm"
alias nopm="npm"
_add_alias nom npom nopm


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

# On Termux (Android), the hostname command will always return "localhost"
# The "true" hostname can only be retrieved through the Termux APIs
if command -v termux-setup-storage >/dev/null 2>&1; then
    export HOSTNAME="$(getprop net.hostname)"
    export HOSTNAME_TERMUX=1
fi

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
        comp_ssh_hosts=$(
          cat ~/.ssh/known_hosts | \
              cut -f 1 -d ' ' | \
              sed -e s/,.*//g | \
              grep -v ^# | \
              uniq | \
              grep -v "\[" ;
          cat ~/.ssh/config | \
              grep "^Host " | \
              awk '{print $2}'
        )
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}

# By default, OSX doesn't autocomplete hosts in .ssh/config
if [[ -z "$DISABLE_OSX_SSH_COMPLETION" ]] && [[ "$OSTYPE" == "darwin"* ]]; then
    complete -F _complete_ssh_hosts ssh
fi


###
# Ref: https://www.reddit.com/r/commandline/comments/kbeoe/you_can_make_readline_and_bash_much_more_user/
#
# Enable case-insensitive completions
#
bind 'set completion-ignore-case on'
#
# Only display the last N characters needed to select
# different completion suggestions.
#
bind 'set completion-prefix-display-length 2'



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


function __conda_ps1
{
    if [[ ! -z "$CONDA_DEFAULT_ENV" ]] && [[ "$CONDA_DEFAULT_ENV" != "base" ]]; then
        if [ -z "${PYTHON_VERSION+x}" ]; then
            PYTHON_VERSION="$(python -V 2>&1 | awk '{print $NF}')"
        fi
        echo "[conda:${CONDA_DEFAULT_ENV} :: $PYTHON_VERSION]"
    fi
}



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
    user="${USER:-${USERNAME:-$(whoami)}}"

    # If user is root, display the username in red
    if [ "$user" = "root" ]; then
        color='\e[0;31m'
    else
        color='\e[0;36m'
    fi

    echo -e ${color}${user}'\e[m'
}

ps1_line1='# \[\e[0;31m\]\#\[\e[m\] \[\e[1;32m\]\t\[\e[m\] \[\e[0;32m\]\D{%Y/%m/%d}\[\e[m\] `ps1_user`\[\e[90m\]@${HOSTNAME:=$(hostname)}$([ -z "$HIDE_HOSTNAME_WARNING" ] && echo -e " \[\e[41m\e[97m\][!]")\[\e[m\]'
ps1_line2='# \[\e[1;33m\]\w\[\e[m\]'
ps1_line3='#\[\e[0;35m\]$(__git_ps1)$(svn_branch)\[\e[m\] \[\e[0;33m\]$(__venv_ps1)$(__conda_ps1)\[\e[m\]\012`echo \# > ${TMPDIR:-/tmp}/.$$.cmdnum`'

if [[ "$OSTYPE" == "darwin"* ]]; then
    ps1_marker='\[$(iterm2_prompt_mark)\]'
else
    ps1_marker=''
fi

export PS1="\012${ps1_line1}\012${ps1_line2}\012${ps1_line3}${ps1_marker}"



###################
# COMMAND SUMMARY #
###################
#
# Prints the last command's elapsed time, exit code, and an explanation of the
# exit code (if applicable).
#
#  (Heavily stolen from https://github.com/jichu4n/bash-command-timer)
#
# Looks like:
#
#    # ✔ [0     ] [1s003   ]
#    # 2 16:47:42 2020/06/28 user@host
#    # ~
#    #
#
#    # ! [1     ] [2s003   ] general warning/error
#    # 3 16:47:48 2020/06/28 user@host
#    # ~
#    #
#
#    # ‼ [2     ] [3s583   ] general error
#    # 4 16:48:06 2020/06/28 user@host
#    # ~
#    #
#
#    # ‼ [130   ] [4s903   ] 130 - 128 = 2, SIGINT
#    # 5 16:48:27 2020/06/28 user@host
#    # ~
#    #
#

###
# Called at beginning of $PROMPT_COMMAND to persist the command's exit code
# and end time.
#
function _yak_command_post() {
    _YAK_FINAL_EXIT="$_YAK_EXIT"

    if [ -z "$_YAK_COMMAND_START_TIME" ]; then
        return
    fi

    _YAK_COMMAND_END_TIME=$(date '+%s%N')
}

###
# Called at end of $PROMPT_COMMAND to print the command summary, including
# elapsed time, exit code, and exit code explanation.
#
function _yak_command_summary() {
    _YAK_AT_PROMPT=1

    if [ -z "$_YAK_COMMAND_START_TIME" ] || [ -z "$_YAK_COMMAND_END_TIME" ]; then
        return
    fi

    local MSEC=1000000
    local SEC=$(($MSEC * 1000))
    local MIN=$((60 * $SEC))
    local HOUR=$((60 * $MIN))
    local DAY=$((24 * $HOUR))

    local command_time=$(($_YAK_COMMAND_END_TIME - $_YAK_COMMAND_START_TIME))
    local num_days=$(($command_time / $DAY))
    local num_hours=$(($command_time % $DAY / $HOUR))
    local num_mins=$(($command_time % $HOUR / $MIN))
    local num_secs=$(($command_time % $MIN / $SEC))
    local num_msecs=$(($command_time % $SEC / $MSEC))

    local time_str=""
    if [ $num_days -gt 0 ]; then
        time_str="${time_str}${num_days}d "
    fi
    if [ $num_hours -gt 0 ]; then
        time_str="${time_str}${num_hours}h "
    fi
    if [ $num_mins -gt 0 ]; then
        time_str="${time_str}${num_mins}m "
    fi

    local num_msecs_pretty=$(printf '%03d' $num_msecs)
    time_str="${time_str}${num_secs}s${num_msecs_pretty}"

    local exit_icon=""
    local exit_color=231  # white
    if [ "$_YAK_FINAL_EXIT" = "0" ]; then
        exit_icon="✔"
        exit_color=28
    elif [ "$_YAK_FINAL_EXIT" = "1" ]; then
        exit_icon="!"
        exit_color=137
    elif [ "$_YAK_FINAL_EXIT" -gt 1 ]; then
        exit_icon="‼"
        exit_color=88
    fi

    # Use the width of the cmdnum to ensure spacing is consistent with next prompt
    local cmdnum=$(cat ${TMPDIR:-/tmp}/.$$.cmdnum)
    local next_cmdnum=$((cmdnum + 1))
    local next_cmdnum_spacing="${next_cmdnum//?/ }"
    local exit_icon_spacing="${next_cmdnum_spacing:1}"

    local base_color=243
    local time_color=62

    local exit_explain=$(_explain_exit_code $_YAK_FINAL_EXIT)

    printf '\n%s# %s%s%s %s[%s%-6s%s] [%s%-8s%s] %s\x1B[m' \
        "$(_fmt_256 $base_color)" \
        "$(_fmt_256 $exit_color)" "$exit_icon" "$exit_icon_spacing" \
        "$(_fmt_256 $base_color)" \
        "$(_fmt_256 $exit_color)" "$_YAK_FINAL_EXIT" \
        "$(_fmt_256 $base_color)" \
        "$(_fmt_256 $time_color)" "${time_str}" \
        "$(_fmt_256 $base_color)" \
        "$exit_explain"

    unset _YAK_COMMAND_START_TIME
    unset _YAK_COMMAND_END_TIME
    unset _YAK_FINAL_EXIT
    unset _YAK_EXIT
}

function _explain_exit_code() {
    local exit_code=$1

    local SIG_MAX=64
    local EXIT_SIG_MIN=128
    local EXIT_SIG_MAX=$((EXIT_SIG_MIN + SIG_MAX))

    local msg=''
    local sig
    local signame

    case $exit_code in
    # Ref: https://tldp.org/LDP/abs/html/exitcodes.html
    1)   msg='general warning/error' ;;
    2)   msg='general error' ;;
    126) msg='command invoked cannot execute' ;;
    127) msg='command not found' ;;
    1[2-9]?)
        if (( EXIT_SIG_MIN <= exit_code && exit_code < EXIT_SIG_MAX )); then
            sig=$((exit_code - EXIT_SIG_MIN))
            signame=$(kill -l $sig)
            msg="$exit_code - $EXIT_SIG_MIN = $sig, SIG$signame"
        fi
        ;;

    # Ref: /usr/include/sysexits.h
    64)  msg='EX_USAGE: command line usage error' ;;
    65)  msg='EX_DATAERR: data format error' ;;
    66)  msg='EX_NOINPUT: cannot open input' ;;
    67)  msg='EX_NOUSER: addressee unknown' ;;
    68)  msg='EX_NOHOST: host name unknown' ;;
    69)  msg='EX_UNAVAILABLE: service unavailable' ;;
    70)  msg='EX_SOFTWARE: internal software error' ;;
    71)  msg="EX_OSERR: system error (e.g., can't fork)" ;;
    72)  msg='EX_OSFILE: critical OS file missing' ;;
    73)  msg="EX_CANTCREAT: can't create (user) output file" ;;
    74)  msg='EX_IOERR: input/output error' ;;
    75)  msg='EX_TEMPFAIL: temp failure; user is invited to retry' ;;
    76)  msg='EX_PROTOCOL: remote error in protocol' ;;
    77)  msg='EX_NOPERM: permission denied' ;;
    78)  msg='EX_CONFIG: configuration error' ;;
    esac

    if [ -n "$msg" ]; then
        printf '%s' "$msg";
    fi
}

function _fmt_256() {
  printf '\x1B[38;5;%sm' "$1"
}

PROMPT_COMMAND="
  DISABLE_START_LINE=1 _yak_command_post;
  $PROMPT_COMMAND
  DISABLE_START_LINE=1 _yak_command_summary;
"


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
    local EXIT="$?"

    ###
    # Save the exit code of the last command, so we can print it out in our PROMPT_COMMAND
    #
    _YAK_EXIT="$EXIT"

    ###
    # do nothing if completing
    #
    [ -n "$COMP_LINE" ] && return $EXIT

    ###
    # if no command is being executed (idk how), ignore it
    #
    [[ -z "$BASH_COMMAND" ]] && return $EXIT;

    ###
    # don't print anything for the prompt command
    #
    [ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return $EXIT

    ###
    # allow manual omission of START line
    #  (including start-of-line env var cases, e.g. `DISABLE_START_LINE=true echo hi`)
    #
    if [ -n "$DISABLE_START_LINE" ] || [[ "$BASH_COMMAND" == DISABLE_START_LINE=* ]]; then
        return $EXIT
    fi

    ###
    # ignore z (the weighting chdir command) performing its calculations
    #
    [[ "$BASH_COMMAND" == _z* ]] && return $EXIT;

    ###
    # ignore hooks from direnv (the per-directory .env file sourcer)
    #
    [[ "$BASH_COMMAND" == _direnv_hook* ]] && return $EXIT;

    ###
    # Print the start line
    #
    printf '# \x1B[0;31m%s\x1B[m \x1B[1;32m%s \x1B[0;32m%s\x1B[m %s \x1B[0;34m%s\x1B[m\n' \
        "$(cat /tmp/.$$.cmdnum 2>/dev/null || echo 1)" \
        "$(date +%T)" \
        "$(date +'%Y/%m/%d')" \
        "$YAK_START_SYMBOL" \
        "$BASH_COMMAND"

    ###
    # Record the start time of the first command (e.g. if there are multiple
    # piped or conditional commands)
    #
    if [ -n "$_YAK_AT_PROMPT" ]; then
        unset _YAK_AT_PROMPT
        _YAK_COMMAND_START_TIME=$(date '+%s%N')
    fi

    return $EXIT
}


trap 'clean_ps1_cmdnum_file' EXIT;
trap 'preexec_invoke_exec' DEBUG;


# Load all history from historian
# Performed down here, so commands run in our .bashrc don't get recorded
# https://github.com/jcsalterego/historian
DISABLE_START_LINE=true "${REPO_DIR}/bin/hist" import > /dev/null
