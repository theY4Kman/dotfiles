REPO_DIR=$( dirname "${BASH_SOURCE[0]}" )

# Disables history expansion (so I can put exclamation marks in double-quoted 
# commit messages without bash complaining all over me. Pfft, LIKE I CARE, BASH!)
set +H

# Show an asterisk by git branch if working directory is dirty/has changes
export GIT_PS1_SHOWDIRTYSTATE=true
# We override the default venv display, so disable it
export VIRTUAL_ENV_DISABLE_PROMPT=true

# Setup z (https://github.com/theY4Kman/z -- using my own version, which also prints
#          the dir being cd'd to, so it can be used like so: pushd `z mydir`)
source ${REPO_DIR}/z/z.sh
# YOU DON'T KNOW WHO MY SYMLINKS REALLY ARE
export _Z_NO_RESOLVE_SYMLINKS=true

# Convenience function for pushd `z ...`
function pushz() {
    cd=`z $*`
    [ "$cd" ] && pushd $cd
}
# Some symmetry
alias popz=popd

# Displays the current activated virtualenv
__venv_ps1 ()
{
    if [ -n "${VIRTUAL_ENV}" ]; then
        echo [${VIRTUAL_ENV##*/}]
    fi
}

###########
# ALIASES #
###########

# general
alias grep="grep --color=auto -i"

# git-related
alias gs="git status"
alias gm="git co master"
alias gd="git diff"
alias gdc="git diff --cached"
alias gaa="git add --all"
alias gmm="git merge master"

# Picked up from Dan @ StyleSeat
alias pmp="python manage.py"
# Matching hivelocity
alias djp="django-admin.py"

export EDITOR=vim

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

clean_hostname=${HOSTNAME//[^a-zA-Z0-9]/}
fourth=`expr ${#clean_hostname} / 4`
h=$clean_hostname
hstn=${h:0:1}${h:$fourth:1}${h:$fourth*2:1}${h:$fourth*3:1}

# Looks like:
#   #17 hstn 18:47:23 2013/05/23 ~/programming/code-tests (vcs-branch *) [myvirtualenv]
# Benefits:
#  - Begins with a hash, so it can be copied accidentally without bollocksing up commands
#  - Ends with a newline, so commands don't get smushed easily
#  - Colors create contrast from command output, easily showing command and command output boundaries
#  - After Enter is hit at prompt, a line is printed with the date and time
#    When the command completes, the PS1 will be printed with date and time,
#    Allowing the measurement of how long a command takes
#  - Each ### START ### line prints the command executed in expanded form,
#    revealing what's actually being run behind aliases and the such.
#  - 'hstn' is 4 a string of 4 chars taken from the hostname at evenly spaced positions.
#    This is to display a unique identifier for the machine without extending the PS1 much
# Disadvantages:
#  - SO MANY LINES, ALWAYS PRINTING, AHHHHHHHHHH
export PS1='\n#\e[0;31m\#\e[m $hstn \e[1;32m\t\e[m \e[0;32m\D{%Y/%m/%d}\e[m \e[1;33m\w\e[m\e[0;35m$(__git_ps1)$(svn_branch)\e[m \e[0;33m$(__venv_ps1)\e[m\n`echo \# > /tmp/.$$.cmdnum`'
 
preexec_invoke_exec () {
    [ -n "$COMP_LINE" ] && return  # do nothing if completing
    # The _z is for z, the weighting chdir db command. Let's hope we never need to run _zach_is_awesome again.
    # Really, I should be testing for $PROMPT_COMMAND, because that's what the first test is for. Otherwise, the echo is run twice every Enter.
    if [[ "$BASH_COMMAND" == _z* ]] || [[ -z "$BASH_COMMAND" ]]; then
        return
    fi
    echo -e '#\e[0;31m'`cat /tmp/.$$.cmdnum 2>/dev/null || echo 1`'\e[m' $hstn '\e[1;32m'`date +%T` '\e[0;32m'`date +'%Y/%m/%d'`'\e[m ####### START ###### \e[0;34m'$BASH_COMMAND'\e[m'
}
trap 'preexec_invoke_exec' DEBUG

