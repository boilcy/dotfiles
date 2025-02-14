function cat --wraps=bat --description 'alias cat=bat'
    if type -f bat &>/dev/null
        command bat $argv
    else
        command cat $argv
    end
end