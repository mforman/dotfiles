#!/usr/bin/env bash

case "$1" in
  brew) echo "" ;;
  colima|docker|docker-compose|stern|lazydocker) echo "󰡨" ;;
  psql) echo "" ;;
  kuberlr|kubectl|k9s) echo "" ;;
  nvim|vim) echo "" ;;
  make) echo "" ;;
  go) echo "" ;;
  fish) echo "" ;;
  zsh|bash) echo "" ;;
  htop) echo "" ;;
  cargo) echo "" ;;
  sudo) echo "" ;;
  git|gh|lazygit) echo "" ;;
  lua) echo "󰢱" ;;
  wget|curl) echo "󰇚" ;;
  ruby) echo "" ;;
  python|poetry|pip) echo "" ;;
  pwsh|cmd) echo "" ;;
  node|npm) echo "󰎙" ;;
  dotnet) echo "󰌛" ;;
  *) echo "" 
esac
