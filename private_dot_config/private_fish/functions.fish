# Operation and maintenance
function killf
    if ps -ef | sed 1d | fzf -m | awk '{print $2}' >$TMPDIR/fzf.result
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

# Audio and video processing
function stabilize --description "stabilize a video"
    set -l vid $argv[1]
    ffmpeg -i "$vid" -vf vidstabdetect=stepsize=32:result="$vid.trf" -f null -
    ffmpeg -i "$vid" -b:v 5700K -vf vidstabtransform=interpol=bicubic:input="$vid.trf" "$vid.mkv"
    # :optzoom=2 seems nice in theory but i dont love it. kinda want a combo of 1 and 2. (dont zoom in past the static zoom level, but adaptively zoom out to full when possible)
    ffmpeg -i "$vid" -i "$vid.mkv" -b:v 3000K -filter_complex hstack "$vid.stack.mkv"
    # vid=Dalton1990/Paultakingusaroundthehouseagai ffmpeg -i "$vid.mp4" -i "$vid.mkv" -b:v 3000K -filter_complex hstack $HOME/Movies/"Paultakingusaroundthehouseagai.stack.mkv"
    command rm $vid.trf
end


# Environment 
function conda -d 'lazy initialize conda'
    functions --erase conda
    eval /opt/miniconda3/bin/conda "shell.fish" hook | source
    # There's some opportunity to use `psub` but I don't really understand it.
    conda $argv
end


function gemi -d 'using https://github.com/simonw/llm-gemini'
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

function openai -d 
    # using llm. same dealio as above
    if test -z "$argv[1]"
        llm chat --continue -m gpt-4o
    else
        llm prompt -m gpt-4o "$argv" && echo "⬇️… and now rendered…⬇️" && llm logs -r | glow
    end
end
