export VIRTUAL_ENV_DISABLE_PROMPT=disabled

source /home/they4kman/software/z/z.sh

__venv_ps1 ()
{
    if [ -n "${VIRTUAL_ENV}" ]; then
        echo [${VIRTUAL_ENV##*/}]
    fi
}

alias gs="git status"
alias gm="git co master"
alias gd="git diff"
alias gdc="git diff --cached"
alias gaa="git add --all"
alias pmp="python manage.py"

export EDITOR=vim

export "PS1=\n#\e[0;31m\#\e[m \e[1;32m\t\e[m \e[0;32m\D{%Y/%m/%d}\e[m \e[1;33m\w\e[m\e[0;35m\$(__git_ps1)\e[m \e[0;33m\$(__venv_ps1)\e[m\n"
