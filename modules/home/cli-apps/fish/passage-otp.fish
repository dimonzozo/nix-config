# Completions for passage-otp: suggest passage store entries the same way `passage` does.

function __fish_passage_otp_get_prefix
    if set -q PASSAGE_DIR
        realpath -- "$PASSAGE_DIR"
    else
        echo "$HOME/.passage/store"
    end
end

function __fish_passage_otp_print_entries
    set -l prefix (__fish_passage_otp_get_prefix)
    set -l matches $prefix/**.age
    printf '%s\n' $matches | sed "s#$prefix/\(.*\).age#\1#"
end

# Disable file completion, offer the -c flag and the list of entries.
complete -c passage-otp -f
complete -c passage-otp -f -s c -d 'Copy the generated code to the clipboard'
complete -c passage-otp -f -a '(__fish_passage_otp_print_entries)' -d 'passage entry'
