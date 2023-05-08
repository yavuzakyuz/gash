#!/bin/bash

# 🎯 Set default values 
width=40
height=10
label="yavuzakyuz/gash"

# 🧩 Parse command line arguments with finesse
while getopts "w:h:l:" opt; do
  case "$opt" in
    w) width=$OPTARG ;;
    h) height=$OPTARG ;;
    l) label=$OPTARG ;;
    *) echo "Invalid option: -$opt" >&2; exit 1 ;;
  esac
done

# 📐 Measure the terminal window dimensions
read -r rows cols <<< "$(stty size)"

# 🔍 Calculate the position of the box with precision
new_row=$(( (rows - height) / 2 ))
new_col=$(( (cols - width) / 2 ))

# 🚦 Check if the box is fully visible on the terminal
if (( new_row < 0 || new_col < 0 )); then
  echo "Error: Box dimensions are too large for the terminal" >&2
  exit 1
fi

# 🏷️ Set the header text
header=$label

# 📍 Calculate the position of the header
header_row=$new_row
header_col=$(( (new_col + width / 2) - (${#header} / 2) ))

button="Press X to Exit"

# 📏 Calculate the position of the button
button_row=$((new_row + height - 1))
button_col=$(( (new_col + width / 2) - (${#button} / 2) ))

clear

# ✏️  Draw the header
printf "\e[%d;%dH%s" $header_row $header_col "$header"

# 📦 Draw top of the box
topleft="╭"
topright="╮"
topfill="─"
printf "\e[%d;%dH%s" $((header_row + 1)) $new_col "$topleft"
for ((i=1; i<$width-1; i++)); do printf "%s" "$topfill"; done
printf "%s" "$topright"

# 📦 Draw sides of the box
leftfill="│"
rightfill="│"
for ((i=2; i<$height-1; i++)); do
    printf "\e[%d;%dH%s" $((new_row+i)) $new_col "$leftfill"
    printf "\e[%d;%dH%s" $((new_row+i)) $((new_col+width-1)) "$rightfill"
done

# 📦 Draw the bottom of the box
bottomleft="╰"
bottomright="╯"
bottomfill="─"
printf "\e[%d;%dH%s" $((new_row + height - 1)) $new_col "$bottomleft"
for ((i=1; i<$width-1; i++)); do printf "%s" "$bottomfill"; done
printf "%s" "$bottomright"

# Draw the button
printf "\e[%d;%dH%s" $button_row $button_col "$button"

# Stty for disabling buffer change
stty -echo -icanon

# Move the cursor to the button start position
printf "\e[%d;%dH" $button_row $button_col

# Wait for the user to press "x" before exiting
while true; do
  read -s -n1 key
  if [[ "$key" == "x" ]]; then
    break
    clear
  fi
done

# Stty enable buffer again 
stty echo icanon

