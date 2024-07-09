if status is-interactive
    # Commands to run in interactive sessions can go here
end

# seperated files
source ~/.config/fish/path.fish
source ~/.config/fish/aliases.fish
source ~/.config/fish/functions.fish
# local file for individual machine
source ~/.config/fish/extra.fish

# pipx
set PATH $PATH /home/yc/.local/bin

# config management by git bare repo
# abbr --add config git --git-dir=$HOME/.cfg/ --work-tree=$HOME