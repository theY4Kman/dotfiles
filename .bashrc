REPO_DIR=$( cd $(dirname "${BASH_SOURCE[0]}") ; pwd )

# Disables history expansion (so I can put exclamation marks in double-quoted 
# commit messages without bash complaining all over me. Pfft, LIKE I CARE, BASH!)
set +H

# vim bindings, yeah!
set -o vi

# Setup z (https://github.com/theY4Kman/z -- using my own version, which also prints
#          the dir being cd'd to, so it can be used like so: pushd `z mydir`)
Z_PATH=${REPO_DIR}/z/z.sh
if [ -e $Z_PATH ]; then
    source $Z_PATH
fi
# YOU DON'T KNOW WHO MY SYMLINKS REALLY ARE
export _Z_NO_RESOLVE_SYMLINKS=true

# Convenience function for pushd `z ...`
function pushz() {
    cd=`z $*`
    [ "$cd" ] && pushd $cd
}
# Some symmetry
alias popz=popd




###########
# ALIASES #
###########

# general
alias grep="grep --color=auto -i"

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


# I use Terminator, usually having 6+ terminals open in the same window. I SSH
# into a lot of boxes, and as they now all use this .bashrc, their PS1s are all
# the same. I needed a way to differentiate machines, but as my PS1 was already
# enormous, I didn't want to push it.
#
# This grabs 4 characters at evenly spaced positions for display in the PS1.
# It's worked very well thus far, giving a unique identifier for all the boxes
# I connect to. However, in the future I may want to add some logic to prefer
# numbers in the hostname, so when I connect to three numbered boxes (e.g.
# gluster1, gluster2, gluster3), the name still ends up unique.
clean_hostname=${HOSTNAME//[^a-zA-Z0-9]/}
fourth=`expr ${#clean_hostname} / 4`
h=$clean_hostname
hstn=${h:0:1}${h:$fourth:1}${h:$fourth*2:1}${h:$fourth*3:1}


#############
# YAK'S PS1 #
#############
#
# Looks like:
#   #17 hstn 18:47:23 2013/05/23 ~/programming/code-tests (vcs-branch *) [myvirtualenv]
# Benefits:
#  - Begins with a hash, so it can be copied accidentally without bollocksing up commands
#  - Ends with a newline, so commands don't get smushed easily
#    Also, commands can be selected with a triple-click, with a middle-click to run them (at least in Terminator)
#  - Colors create contrast from command output, easily showing command and command output boundaries
#  - 'hstn' is 4 a string of 4 chars taken from the hostname at evenly spaced positions.
#    This is to display a unique identifier for the machine without extending the PS1 much
# Downsides:
#  - SO MANY LINES, ALWAYS PRINTING, AHHHHHHHHHH-ee couldn't give a shit.
export PS1='\n# \e[0;31m\#\e[m $hstn \e[1;32m\t\e[m \e[0;32m\D{%Y/%m/%d}\n\e[m# \e[1;33m\w\e[m\n#\e[0;35m$(__git_ps1)$(svn_branch)\e[m \e[0;33m$(__venv_ps1)\e[m\n`echo \# > /tmp/.$$.cmdnum`'


##############
# START LINE #
##############
#
# Looks like:
#   #17 hstn 18:47:23 2013/05/23 ~/programming/code-tests (vcs-branch *) [myvirtualenv]
#   la ~ | grep yo
#   #17 tkst 19:12:55 2013/09/13 ####### START ###### ls --color=auto -A ~
#   #17 tkst 19:12:55 2013/09/13 ####### START ###### grep --color=auto -i yo
#
# Benefits
#  - After Enter is hit at prompt, a line is printed with the date and time
#    When the command completes, the PS1 will be printed with date and time,
#    Allowing the measurement of how long a command takes
#  - Each ### START ### line prints the command executed in expanded form,
#    revealing what's actually being run behind aliases and the such.
# Downsides
#  - A line is printed for every command in a pipeline, which can lead to many
#    START lines. (Again, I'd rather have more information than less.
#    After all, what is infinite scrollback for, anyway?)
preexec_invoke_exec () {
    [ -n "$COMP_LINE" ] && return  # do nothing if completing
    # The _z is for z, the weighting chdir db command.
    # Really, I should be testing for $PROMPT_COMMAND, because that's what the first test is for. Otherwise, the echo is run twice every Enter.
    if [[ "$BASH_COMMAND" == _z* ]] || [[ -z "$BASH_COMMAND" ]]; then
        return
    fi
    echo -e '# \e[0;31m'`cat /tmp/.$$.cmdnum 2>/dev/null || echo 1`'\e[m' $hstn '\e[1;32m'`date +%T` '\e[0;32m'`date +'%Y/%m/%d'`'\e[m ####### START ###### \e[0;34m '$BASH_COMMAND'\e[m'
}
trap 'preexec_invoke_exec' DEBUG

