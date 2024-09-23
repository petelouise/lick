#!/bin/bash

# Check for user input
if [[ -z "$1" ]]; then
	gum style --foreground 197 --bold "Usage: $0 <path-to-file>"
	exit 1
fi

# Check if the file exists before using realpath
if [[ ! -f "$1" ]]; then
	gum style --foreground 197 --bold "Error: The file '$1' does not exist."
	exit 1
fi

FILE_PATH=$(realpath $1)
BASENAME=$(basename -- "$FILE_PATH")
FILENAME="${BASENAME%.*}" # Remove the extension from the basename

# Using Gum for styled confirmation message
if ! gum confirm --prompt.foreground 57 --prompt.bold "Would you like to process and link '$(gum style --foreground 82 --bold "$BASENAME")'?" --affirmative "$(gum style --foreground 82 "Yes, proceed!")" --negative "$(gum style --foreground 190 "No, cancel")"; then
	gum style --foreground 190 "Processing canceled."
	exit 1
fi

process_file() {
	local file=$1
	local filename=$2
	local bin_dir="$HOME/.her/bin"

	# Ensure the bin directory exists
	mkdir -p "$bin_dir"

	# Check for shebang
	if head -n 1 "$file" | grep -qE "^#!"; then
		# Make file executable
		chmod +x "$file"
		# Create or update symlink in bin directory without the extension
		local link_path="$bin_dir/$filename"
		ln -sf "$file" "$link_path"
		gum style --foreground 153 --bold "Processed and linked: $file -> $link_path"
	else
		gum style --foreground 175 --bold "No shebang found in: $file"
	fi
}

process_file "$FILE_PATH" "$FILENAME"
