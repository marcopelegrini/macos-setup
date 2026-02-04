#!/bin/bash

HOME=~
DOTFILES=$HOME/OSX/dotfiles

# Parse arguments
AUTO_SKIP=false
if [[ "$1" == "--no" ]]; then
  AUTO_SKIP=true
fi

cd "$DOTFILES" || exit 1

for file in .*; do
  [[ "$file" == "." || "$file" == ".." || "$file" == ".DS_Store" ]] && continue
  
  target="$HOME/$file"
  
  if [[ -e "$target" ]]; then
    if [[ "$AUTO_SKIP" == true ]]; then
      echo "Skipping $file (already exists)"
      continue
    fi
    read -p "$target already exists. Remove it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm "$target"
    else
      echo "Skipping $file"
      continue
    fi
  fi
  
  ln -s "$DOTFILES/$file" "$target"
  echo "Linked $file"
done