#!/bin/bash
mkdir -p ~/.backup

dotfiles_dir="$( cd "$(dirname "$0")" && pwd )"

for pkg in fish git kanshi mako nvim pam_environment sway termite waybar zathura; do
    stow -d ${dotfiles_dir} -t ${HOME} -R ${pkg}
done;
