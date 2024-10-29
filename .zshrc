if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$PATH:/home/mateusz/.cargo/bin:/home/mateusz/.local/bin/
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

docker() {
    if [[ "$1" == "run" ]] && [[ "$2" == "--use-gpu-and-display" ]]; then
        shift 
        shift

        if [ -z "$SUDO_USER" ]
        then
              user=$USER
        else
              user=$SUDO_USER
        fi

        xhost +local:root
        XAUTH=/tmp/.docker.xauth
        if [ ! -f $XAUTH ]
        then
            xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
            if [ ! -z "$xauth_list" ]
            then
                echo $xauth_list | xauth -f $XAUTH nmerge -
            else
                touch $XAUTH
            fi
            chmod a+r $XAUTH
        fi
        command docker run -it --rm \
            --shm-size=1g \
            --ulimit memlock=-1 \
            --env="DISPLAY" \
            --env="QT_X11_NO_MITSHM=1" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" --privileged \
            --device=/dev/usb \
            --device=/dev/video0 \
            --gpus all \
            --env="XAUTHORITY=$XAUTH" \
            --volume="$XAUTH:$XAUTH" \
            --env="NVIDIA_VISIBLE_DEVICES=all" \
            --env="NVIDIA_DRIVER_CAPABILITIES=all" \
            --network=host \
            $@
    else
        command docker $@
    fi
}

git() {
  if [[ "$1" == "clone-dir" ]] ; then
    local repo_url=$2
    local dir=$3
    local repo_name
    repo_name=$(basename "$repo_url" .git)
    git clone -n --depth=1 --filter=tree:0 "$repo_url"
    cd "$repo_name" || exit 1
    git sparse-checkout set --no-cone "$dir"
    git checkout
  else
    command git "$@"
  fi
}

eval "$(zoxide init zsh)"

alias cd=z
alias cdi=zi
alias c="clear"
alias cpy="xclip-copyfile"
alias pst="xclip-pastefile"
alias ct="xclip-cutfile"
alias kitty="setsid kitty"
alias drag="fzf --multi | dragon -x -I -a"
alias ssh='env TERM=xterm-256color ssh'
alias nvim="lvim"
