# Start of profile.sh
{{ if eq .os "darwin" -}}
eval "$(/usr/local/bin/brew shellenv)"
eval "$(pyenv init --path)"
{{ end -}}
# End of profile.sh
