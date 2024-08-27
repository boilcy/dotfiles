# Operation and maintenance
function killf
    if ps -ef | sed 1d | fzf -m | awk '{print $2}' >/tmp/fzf.result
        kill -9 (cat $TMPDIR/fzf.result)
    end
end

function list_paths --description "list paths, in order"
    printf '%s\n' (string split \n $PATH)
end

function md --wraps mkdir -d "Create a directory and cd into it"
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

function whichlink -d "Usage: whichlink <command>"
    set cmd_path (type -p greadlink readlink | head -n 1)
    $cmd_path -f (which $argv)
end

function log -d "Usage: log"
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" $argv |
        fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort='`' \
            --bind 'ctrl-m:execute: 
                echo "{}" | grep -o "[a-f0-9]\{7\}" | head -n 1 | 
                xargs -I % sh -c "git show --color=always % | less -R"'
end

function cp_p -d "Usage: cp_p <source> <destination>"
    rsync -WavP --human-readable --progress $argv[1] $argv[2]
end


function sudo!!
    eval sudo $history[1]
end

# `shellswitch [bash|zsh|fish]`
function shellswitch
    chsh -s /usr/bin/$argv
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

function server -d 'Start a HTTP server in the current dir, optionally specifying the port'
    # arg can either be port number or extra args to statikk
    if test $argv[1]
        if string match -qr '^-?[0-9]+(\.?[0-9]*)?$' -- "$argv[1]"
            set -l port $argv[1]
            python -m http.server $port
        else
            echo "wrong port"
        end

    else
        python -m http.server
    end
end


# Extract archives
function extract
    echo "Usage: extract <file>"
    if not test -f $argv[1]
        echo "'$argv[1]' is not a valid file"
        return 1
    end

    set filename (basename $argv[1])
    set foldername (string split "." $filename)[1]
    set fullpath (perl -e 'use Cwd "abs_path";print abs_path(@ARGV[0])' $argv[1])
    set didfolderexist false

    if test -d $foldername
        set didfolderexist true
        read -P "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
        echo
        if string match -rq '^[Nn]' $argv
            return 1
        end
    end

    mkdir -p $foldername; and cd $foldername
    switch $argv[1]
        case '*.tar.bz2' '*.tb2' '*.tbz' '*.tbz2'
            tar xjf $fullpath
        case '*.tar.gz' '*.tgz' '*.tar.Z' '*.taz'
            tar xzf $fullpath
        case '*.tar.xz' '*.txz'
            tar Jxvf $fullpath
        case '*.tar'
            tar xf $fullpath
        case '*.zip'
            unzip $fullpath
        case '*'
            echo "'$argv[1]' cannot be extracted via extract()"
            cd ..
            if test $didfolderexist = false
                rm -r $foldername
            end
            return 1
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

# Environment 
function conda -d 'lazy initialize conda'
    functions --erase conda
    eval ~/miniconda3/bin/conda "shell.fish" hook | source
    conda $argv
end
