# Extract archives
function extract -d 'Usage: extract <file> [-d directory] [-o] [-h] [-v]'
    argparse -n extract \
        'h/help' \
        'd/dir=' \
        'o/overwrite' \
        'v/verbose' -- $argv

    if set -q _flag_help
        echo "Usage: extract [file] [Options]"
        echo "Options:"
        echo "  -h, --help        display this help and exit"
        echo "  -d, --dir=DIR     extract to directory (default: current dir)"
        echo "  -o, --overwrite   overwrite existing files without prompting"
        echo "  -v, --verbose     verbose output"
        return
    end

    if test (count $argv) -lt 1
        echo "Error: Invalid number of arguments"
        return 1
    end

    set -l file $argv[1]
    if test -z $file
        echo "Error: archive file is required"
        return 1
    end
    if not test -f $file
        echo "'$file' is not a valid file"
        return 1
    end

    # set extract path
    set extract_dir .
    if set -q _flag_dir
        set extract_dir $_flag_dir
    end
    
    set overwrite false
    if set -q _flag_overwrite
        set overwrite true
    end

    set verbose false
    if set -q _flag_verbose
        set verbose true
    end

    # Trying to extract
    set filename (basename $file)
    set foldername (string split "." --max 1 $filename)[1]
    set fullpath (realpath $file)

    if not test -d "$extract_dir/$foldername"
        set didfolderexist false
    else
        set didfolderexist true
        if test $overwrite = false
            read -P "$extract_dir/$foldername already exists, do you want to overwrite it? (y/n) " -n 1
            echo
            if string match -rq '^[Nn]' $argv
                return 1
            end
        end
    end

    mkdir -p "$extract_dir/$foldername"; and cd "$extract_dir/$foldername"
    switch $file
        case '*.tar.bz2' '*.tb2' '*.tbz' '*.tbz2'
            echo "Executing: tar xjf $fullpath"
            tar xjf $fullpath
        case '*.tar.gz' '*.tgz' '*.tar.Z' '*.taz'
            echo "Executing: tar xzf $fullpath"
            tar xzf $fullpath
        case '*.tar.xz' '*.txz'
            echo "Executing: tar Jxvf $fullpath"
            tar Jxvf $fullpath
        case '*.tar'
            echo "Executing: tar xf $fullpath"
            tar xf $fullpath
        case '*.zip'
            echo "Executing: unzip $fullpath"
            unzip $fullpath
        case '*.gz'
            echo "Executing: gzip -dk $fullpath"
            gzip -dk $fullpath
        case '*'
            echo "'$file' cannot be extracted via extract()"
    end

    # Check if extraction was successful
    if test $status -ne 0
        echo "Error extracting '$file': $status"
        cd ..
        if test $didfolderexist = false
            rm -r "$extract_dir/$foldername"
        end
        return 1
    end

    # Check for a single directory after extraction
    set subdirs (find . -maxdepth 1 -type d)
    if test (count $subdirs) -eq 2  # Count includes the current directory '.'
        set sub_dir_name (basename $subdirs[2])
        echo "Moving contents of '$sub_dir_name' up a level"
        cd ..
        # 1. rename current folder with a random name, to avoid same name
        set randomname "temp_$(uuidgen)"
        mv "$foldername" "$randomname"
        # 2. move sub dir up
        mv "$randomname/$sub_dir_name" ./
        # 3. remove random folder, it's empty
        rmdir "$randomname"
    else
        cd ..
    end
end