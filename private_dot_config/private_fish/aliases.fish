

# Navigation
function ..    ; cd .. ; end
function ...   ; cd ../.. ; end
function ....  ; cd ../../.. ; end
function ..... ; cd ../../../.. ; end

# Utilities
function grep     ; command grep --color=auto $argv ; end

## abbreviations
abbr mv 'mv -v'
abbr rm 'rm -v'
abbr cp 'cp -v'

## typos

## alias

alias ag='command ag -W (math $COLUMNS - 14)'  

# for counting instances.. `ag -o 'metadata","name":".*?"' trace.json | sorteduniq`
alias sorteduniq="sort | uniq -c | sort --reverse --ignore-leading-blanks --numeric-sort" # -rbn
alias sorteduniq-asc="sort | uniq -c | sort --ignore-leading-blanks --numeric-sort"  # -bn

# Operation and maintenance
alias diskspace_report="df -P -kHl"
alias free_diskspace_report="diskspace_report"
# File size
alias fs="stat -f \"%z bytes\""
alias ungz="gunzip -k"

# Networking. IP address, dig, DNS
alias wget="curl -O"
# Recursively delete `.DS_Store` files
alias cleanup_dsstore="find . -name '*.DS_Store' -type f -ls -delete"

# pretty sure watchexec has just won my heart after years of using `entr`
# alias reportwatch 'watchexec "node build/build-report-components.js && node build/build-report.js --psi && node build/build-sample-reports.js && echo \$(date) && yarn eslint --fix report/renderer/components.js" && bash core/scripts/copy-util-commonjs.sh'

# Subcommand expansion with `abbr`
function subcommand_abbr
  set -l cmd "$argv[1]"
  set -l short "$argv[2]"
  set -l long "$argv[3]"

  if not string match --regex --quiet '^[a-z]*$' "$short"
    or not string match --regex --quiet '^[a-z- ]*$' "$long"
    echo "Scary unsupported alias or expansion $short $long"; exit 1; 
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

# git subcommand
subcommand_abbr git c "commit -am"
subcommand_abbr git tc "commit -am"
subcommand_abbr git cm "commit --no-all -m"
subcommand_abbr git co "checkout"
subcommand_abbr git c "commit -am"
subcommand_abbr git s "status"
subcommand_abbr git ts "status"
subcommand_abbr git amend "commit --amend --all --no-edit"
subcommand_abbr git hreset "reset --hard"
subcommand_abbr git cp "cherry-pick"
subcommand_abbr git cherrypick "cherry-pick"
subcommand_abbr git dif "diff"

subcommand_abbr git db "diffbranch"
subcommand_abbr git dbt "diffbranch-that"

# can only do one of these unless I adopt lucas's setup.
subcommand_abbr npm i "install"
subcommand_abbr pnpm i "install"

function gemi
  # using https://github.com/simonw/llm-gemini and llm
  # no args? chat.  otherwise use prompt, and allow unquoted stuff to work too
  #    gemi
  #    gemi tell me a joke      
  #    gemi "tell me a joke"
  if test -z "$argv[1]"
    # no markdown parsing here without some real fancy stuff. because you dont want to send to markdown renderer (glow) inbetween backticks, etc.
    llm chat --continue -m gemini-1.5-pro-latest
  else
    llm prompt -m gemini-1.5-pro-latest "$argv" && echo "⬇️… and now rendered…⬇️" && llm logs -r | glow
  end
end

function openai
  # using llm. same dealio as above
  if test -z "$argv[1]"
    llm chat --continue -m gpt-4o
  else
    llm prompt -m gpt-4o "$argv" && echo "⬇️… and now rendered…⬇️" && llm logs -r | glow
  end
end