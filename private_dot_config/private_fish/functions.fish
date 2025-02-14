# tabby prompt
function __tabby_working_directory_reporting --on-event fish_prompt
    echo -en "\e]1337;CurrentDir=$PWD\x7"
end

# git related
function log -d "Usage: log"
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" $argv |
        fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort='`' \
            --bind 'ctrl-m:execute: 
                echo "{}" | grep -o "[a-f0-9]\{7\}" | head -n 1 | 
                xargs -I % sh -c "git show --color=always % | less -R"'
end

# System Admin
function mkcd --wraps mkdir -d "Create a directory and enter it"
    command mkdir -p $argv
    if test $status = 0
        switch $argv[(count $argv)]
            case '-*'
            case '*'
                cd $argv[(count $argv)]
                return
        end
    end
end

function killf -d "Kill processes interactively via fzf"
    if ps -ef | sed 1d | fzf -m | awk '{print $2}' >/tmp/fzf.result
        kill -9 (cat $TMPDIR/fzf.result)
    end
end

function fp -d "Find process by name with highlight"
    ps aux | grep -i $argv | grep -v grep
end

function sudo!! -d "Re-run last command with sudo"
    if test -n "$history[1]"
        eval sudo $history[1]
    else
        echo "No command history found"
    end
end

function folderwc --description "Count lines and files in a directory for specific file types"
    # Check if a directory and file suffixes are provided as arguments
    if test (count $argv) -lt 2
        echo "Usage: folderwc <directory_path> <file_suffix1> [<file_suffix2> ...]"
        echo "Example: folderwc /path/to/directory py sh cpp"
        return 1
    end

    # Store the directory path
    set dir_path $argv[1]
    set --erase argv[1]

    # Store the file suffixes
    set file_suffixes $argv

    # Check if the provided path is a directory
    if not test -d $dir_path
        echo "The provided path is not a directory."
        return 1
    end

    set total_lines 0
    set total_files 0

    # Process each file suffix
    for suffix in $file_suffixes
        # Count lines in all files with the specified suffix recursively
        set suffix_lines (find $dir_path -name "*.$suffix" -type f -print0 | xargs -0 cat | wc -l)
        set total_lines (math $total_lines + $suffix_lines)

        # Count the number of files with the specified suffix
        set suffix_count (find $dir_path -name "*.$suffix" -type f | wc -l)
        set total_files (math $total_files + $suffix_count)

        # Print the results for each suffix
        echo "Total number of lines in *.$suffix files: $suffix_lines"
        echo "Total number of *.$suffix files: $suffix_count"

        # Calculate and print the average lines per file for each suffix
        if test $suffix_count -ne 0
            set average (math --scale=2 "$suffix_lines / $suffix_count")
            echo "Average lines per *.$suffix file: $average"
        else
            echo "No *.$suffix files found in the directory."
        end
        echo ""
    end

    # Print the overall results only if there are multiple file suffixes
    if test (count $file_suffixes) -gt 1
        echo "Overall statistics:"
        echo "Total number of lines in all specified file types: $total_lines"
        echo "Total number of files of all specified types: $total_files"

        # Calculate and print the overall average lines per file
        if test $total_files -ne 0
            set overall_average (math --scale=2 "$total_lines / $total_files")
            echo "Overall average lines per file: $overall_average"
        else
            echo "No files of the specified types found in the directory."
        end
    end
end

# Network
function myip -d "Get external IP address"
    curl -s https://ipinfo.io/ip
    # 备选方案: dig +short myip.opendns.com @resolver1.opendns.com
end

function portscan -d "Check port availability"
    nc -zv $argv[1] $argv[2] 2>&1 | grep --color=auto succeeded
end

function pyhttp -d "Quick Python HTTP server"
    argparse 'p/port=' -- $argv
    set -q _flag_port; or set _flag_port 8000
    python -m http.server $_flag_port
end

# Dev related
function list_paths --description "list paths, in order"
    printf '%s\n' (string split \n $PATH)
end

function whichlink -d "Usage: whichlink <command>"
    set cmd_path (type -p greadlink readlink | head -n 1)
    $cmd_path -f (which $argv)
end

function now -d "Get timestamp in different formats"
    argparse 's/short' 'f/full' -- $argv
    if set -q _flag_short
        date +"%Y%m%d_%H%M%S"
    else if set -q _flag_full
        date +"%Y-%m-%d %H:%M:%S %Z"
    else
        date +%s
    end
end

function envtemp -d "Create temporary environment"
    set -l old_env (set | grep -vE '^_|fish_')
    fish --command "env > .temp_env"
    and source .temp_env
    rm .temp_env
    echo "Original environment restored"
end

# Common utils
function hf -d "Search history with fzf"
    history | fzf --height=40% --reverse | read -l cmd
    and commandline -rb $cmd
end

function cp_p -d "Usage: cp_p <source> <destination>"
    rsync -WavP --human-readable --progress $argv[1] $argv[2]
end

function fuck -d 'Correct your previous console command'
    set -l exit_code $status
    set -l eval_script (mktemp 2>/dev/null ; or mktemp -t 'thefuck')
    set -l fucked_up_commandd $history[1]
    thefuck $fucked_up_commandd >$eval_script
    . $eval_script
    rm $eval_script
    if test $exit_code -ne 0
        history --delete $fucked_up_commandd
    end
end

# Conda
function conda -d 'lazy initialize conda'
    functions --erase conda
    eval ~/miniconda3/bin/conda "shell.fish" hook | source
    conda $argv
end
