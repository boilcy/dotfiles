# Navigation
function ..
    cd ..
end
function ...
    cd ../..
end
function ....
    cd ../../..
end
function .....
    cd ../../../..
end

# Utilities
function grep
    command grep --color=auto $argv
end

function gateway_ip
    ip route show | grep -i default | awk '{print $3}'
end

function local_ip
    hostname -I | awk '{print $1}'
end

## abbreviations
abbr mv 'mv -v'
abbr rm 'rm -v'
abbr cp 'cp -v'

## typos

## alias
alias ag='command ag -W (math $COLUMNS - 14)'

# for counting instances.. `ag -o 'metadata","name":".*?"' trace.json | sorteduniq`

alias hosts='sudo $EDITOR /etc/hosts'

alias sorteduniq="sort | uniq -c | sort --reverse --ignore-leading-blanks --numeric-sort" # -rbn
alias sorteduniq-asc="sort | uniq -c | sort --ignore-leading-blanks --numeric-sort" # -bn

# Operation and maintenance
alias diskspace_report="df -P -kHl"

# File size
# alias fs="stat -f -c '%z bytes'"
alias fs="stat -f"

# Networking. IP address, dig, DNS

# Subcommand expansion with `abbr`
function subcommand_abbr
    set -l cmd "$argv[1]"
    set -l short "$argv[2]"
    set -l long "$argv[3]"

    if not string match --regex --quiet '^[a-z]*$' "$short"
        or not string match --regex --quiet '^[a-z- ]*$' "$long"
        echo "Scary unsupported alias or expansion $short $long"
        exit 1
    end

    set -l abbr_temp_fn_name (string join "_" "abbr" "$cmd" "$short")
    set -l abbr_temp_fn "function $abbr_temp_fn_name
    set --local tokens (commandline --tokenize)
    if test \$tokens[1] = \"$cmd\"
      echo $long
    else
      echo $short
    end; 
  end; 
  abbr --add $short --position anywhere --function $abbr_temp_fn_name"
    eval "$abbr_temp_fn"
end

# git subcommands
subcommand_abbr git ac "commit -am"  # add & commit
subcommand_abbr git mc "commit -m"   # message commit
subcommand_abbr git co checkout     # checkout
subcommand_abbr git st status        # status
subcommand_abbr git am "commit --amend --all --no-edit"  # amend
subcommand_abbr git hr "reset --hard"  # hard reset
subcommand_abbr git cp cherry-pick   # cherry pick
subcommand_abbr git df diff          # diff

subcommand_abbr git db diffbranch
subcommand_abbr git dbt diffbranch-that

# useful combinations
subcommand_abbr git cob "checkout -b"  # checkout new branch
subcommand_abbr git lga "log --all --graph --decorate"  # log all branches graphically
subcommand_abbr git dfc "diff --cached"  # diff staged changes

# can only do one of these unless I adopt lucas's setup.
subcommand_abbr npm i install
subcommand_abbr pnpm i install