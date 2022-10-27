if status is-interactive
    # Commands to run in interactive sessions can go here
    eval "$(/opt/homebrew/bin/brew shellenv)"
    set PATH $HOME/bin $PATH
    set PATH $HOME/go/bin $PATH
    set PATH $HOME/Library/Python/3.8/bin $PATH
    set PATH $HOME/.cargo/bin $PATH
    set PATH /usr/local/bin $PATH
    # The next line updates PATH for the Google Cloud SDK.
    if [ -f '/Users/t-nakata/Downloads/google-cloud-sdk/path.fish.inc' ]; . '/Users/t-nakata/Downloads/google-cloud-sdk/path.fish.inc'; end
    ssh-add ~/.ssh/github_ed25519
    export CLICOLOR=1
    export LSCOLORS="GxFxCxDxBxegedabagaced"
    alias ag='rg'
    alias go='/Users/t-nakata/go/bin/go1.19'
    # alias go='/Users/t-nakata/go/bin/go1.17'
end

function fish_prompt
     printf '%s' '[' $(date -Iseconds) ']' $PWD (fish_git_prompt) '(k:' $(kube-ctx) ')' '(gcp:' $(gcloud-current) ')' ' $ ' \n
     set_color FF0
     echo '> '
end

function gcloud-current
    set g $(cat $HOME/.config/gcloud/active_config)
    # prod
    if [ "$g" = "" ]; then
      echo "\e[31m$g\e[0m"
    else
      echo $g
    end
end

function kube-ctx
  set k $(kubectl config current-context | sed -e 's/.*\/\(.*\)/\1/')
    # prod
    if [ "$k" = "" ]; then
      echo "\e[31m$k\e[0m"
    else
      echo $k
    end
end

function gconf
  set projData $(gcloud config configurations list | peco)
  if echo "$projData" | grep -E "^[a-zA-Z].*" > /dev/null ; then
    set config $(echo $projData | awk '{print $1}')
    gcloud config configurations activate $config

    echo "=== The current account is as follows ==="
    gcloud config configurations list | grep "$config"

    kubesw
  end
end

function kubesw
    set selected_ctx $(kubectl config get-contexts --no-headers | awk '{print $2}' | xargs printf "%s\n" | sort | peco --query "$1" --prompt '>' | cut -f 3)

    echo $selected_ctx
    if [ -n "$selected_ctx" ]; then
        kubectl config use-context $selected_ctx
    end
end

function gconfset
    gcloud config configurations create $argv
    gcloud config set project $argv
    gcloud config set account t-nakata@mercari.com
end

function gauth
    gcloud auth login --update-adc
end

function goinstall
  go install golang.org/dl/go$argv@latest
  go$argv download
  go$argv version
  which go$argv
end

eval (direnv hook fish)
