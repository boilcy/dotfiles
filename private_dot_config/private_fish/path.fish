# Grab my $PATHs from ~/.bash_extra
set -l PATH_DIRS (cat "$HOME/.bash_extra" | grep "^PATH" | \
    # clean up bash PATH setting pattern
    sed "s/PATH=//" | sed "s/\\\$PATH://")

for entry in (string split \n $PATH_DIRS)
    # resolve the {$HOME} substitutions
    set -l resolved_path (eval echo $entry)
    if contains $resolved_path $PATH;
        continue; # skip dupes
    end
    if test -d "$resolved_path";
        fish_add_path $resolved_path
    end
end


set -l manually_added_paths "
$HOME/.yarn/bin
$GOPATH/bin
"

for entry in (string split \n $manually_added_paths)
    # resolve the {$HOME} substitutions
    set -l resolved_path (eval echo $entry)
    if contains $resolved_path $PATH;
        continue;
    end
    if test -d "$resolved_path";
        fish_add_path $resolved_path
    end
end

# pipx
fish_add_path ~/.local/bin