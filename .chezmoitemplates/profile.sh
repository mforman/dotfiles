# Start of profile.sh
{{ if eq .os "darwin" -}}
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(pyenv init --path)"
{{ end -}}
# End of profile.sh
