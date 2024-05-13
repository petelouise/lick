#!/bin/bash

# Check for user input
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path-to-file>"
    exit 1
fi

# Check if the file exists before using realpath
if [[ ! -f "$1" ]]; then
    echo "Error: The file '$1' does not exist."
    exit 1
fi

# Validate and prepare file information
FILE_PATH=$(realpath $1)
BASENAME=$(basename -- "$FILE_PATH")
FILENAME="${BASENAME%.*}"  # Remove the extension from the basename

# Using Gum to ask for confirmation with a more interactive UI
if ! gum confirm "Would you like to process and link '$BASENAME'?" --affirmative "Yes, proceed!" --negative "No, cancel"; then
    echo "Processing canceled."
    exit 1
fi

# Function to process the file
process_file() {
    local file=$1
    local filename=$2
    local bin_dir="$HOME/bin"

    # Ensure the bin directory exists
    mkdir -p "$bin_dir"

    # Check for shebang
    if head -n 1 "$file" | grep -qE "^#!"; then
        # Make file executable
        chmod +x "$file"
        # Create or update symlink in bin directory without the extension
        local link_path="$bin_dir/$filename"
        ln -sf "$file" "$link_path"
        echo "Processed and linked: $file -> $link_path"
    else
        echo "No shebang found in: $file"
    fi
}

# Process the file
process_file "$FILE_PATH" "$FILENAME"
