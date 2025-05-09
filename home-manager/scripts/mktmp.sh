#!/bin/sh

func_new() {
    # Create a temporary directory
    tmp_dir=$(mktemp -d)

    # Ask for folder name
    if [ -z "$1" ]; then
        echo "Warning: No folder name provided. No symbolic link will be created."
        cd "$tmp_dir"

    else
        # Check if the folder name already exists
        if [ -e "$HOME/.cache/mktmp/$1" ]; then
            echo "Error: '$1' already exists. Please choose a different name."
        else

            # Create the symbolic link with the specified folder name
            ln -s "$tmp_dir" "$HOME/.cache/mktmp/$1"

            echo "'$tmp_dir' -> '$1'" >>"$HOME/.cache/mktmp/config"
            echo "Symbolic link '$HOME/.cache/mktmp/$1' -> '$tmp_dir' created."

            cd "$tmp_dir"
        fi
    fi

}

func_clean_up() {
    # Clean up the temporary directory

    input_file="$HOME/.cache/mktmp/config"
    temp_backup_file=$(mktemp)

    while IFS= read -r line; do
        # Check if the line contains a symlink (has '->')
        if [[ "$line" == *"->"* ]]; then
            # Extract left and right parts
            right=$(echo "$line" | awk -F"->" '{print $1}' | xargs)
            left=$(echo "$line" | awk -F"->" '{print $2}' | xargs | tr -d "'")

            if [[ ! -e "$right" ]]; then
                echo "Target '$right' does not exist. Deleting '$left'"
                rm "$HOME/.cache/mktmp/$left"
            else
                echo "$line" >>"$temp_backup_file"
            fi
        fi
    done <"$input_file"

    # Replace the original file with the backup
    mv "$temp_backup_file" "$input_file"

}

func_follow() {
    # Follow the symbolic link
    input_file="$HOME/.cache/mktmp/config"
    exist=0

    while IFS= read -r line; do
        # Check if the line contains a symlink (has '->')
        if [[ "$line" == *"->"* ]]; then
            # Extract left and right parts
            right=$(echo "$line" | awk -F"->" '{print $1}' | xargs)
            left=$(echo "$line" | awk -F"->" '{print $2}' | xargs | tr -d "'")

            if [[ "$2" = "$left" ]]; then
                cd "$right"
                exist=1
            fi

        fi
    done <"$input_file"

    if [ "$exist" -eq 0 ]; then
        echo "Error: '$(tput setaf 26)$2$(tput sgr0)' does not exist in the config file."
        echo "Please use the -l option to list all symbolic links."

    fi
}

func_list() {
    echo "Listing all symbolic links in the mktmp directory:"

    input_file="$HOME/.cache/mktmp/config"
    while IFS= read -r line; do
        # Check if the line contains a symlink (has '->')
        if [[ "$line" == *"->"* ]]; then
            # Extract left and right parts
            right=$(echo "$line" | awk -F"->" '{print $1}' | xargs)
            left=$(echo "$line" | awk -F"->" '{print $2}' | xargs | tr -d "'")

            echo "- $(tput setaf 26)$left$(tput sgr0) -> $right"

        fi
    done <"$input_file"

    echo "-------------------------------------"
    echo "Total number of symbolic links: $(wc -l <"$input_file")"
    echo "-------------------------------------"
}

func_delete() {
    # Delete the symbolic link
    input_file="$HOME/.cache/mktmp/config"
    temp_backup_file=$(mktemp)

    while IFS= read -r line; do
        # Check if the line contains a symlink (has '->')
        if [[ "$line" == *"->"* ]]; then
            # Extract left and right parts
            right=$(echo "$line" | awk -F"->" '{print $1}' | xargs)
            left=$(echo "$line" | awk -F"->" '{print $2}' | xargs | tr -d "'")

            if [[ "$2" = "$left" ]]; then
                rm "$HOME/.cache/mktmp/$left"
            else
                echo "$line" >>"$temp_backup_file"
            fi
        fi
    done <"$input_file"
    # Replace the original file with the backup
    mv "$temp_backup_file" "$input_file"
}

func_help() {
    echo "Usage: mktmp [-(n|d|f|l|c|h)] [folder_name]"
    echo "  no args: Create a new temporary directory"
    echo "  folder_name: Name of the folder to create a temporary directory and symbolic link to it"
    echo "  -n folder_name: Create a new temporary directory (and symbolic link to it if folder_name is provided)"
    echo "  -d folder_name: Delete the symbolic link to the temporary directory"
    echo "  -d: Delete all files in the mktmp directory"
    echo "  -f: Follow the symbolic link to the temporary directory"
    echo "  -l: List all symbolic links in the mktmp directory"
    echo "  -c: Only clean up the config file"
    echo "  -h: Show this help message"
}

if [ ! -f "$HOME/.cache/mktmp/config" ]; then
    mkdir -p "$HOME/.cache/mktmp"
    touch "$HOME/.cache/mktmp/config"

fi

if [ "$1" = "-n" ]; then
    func_clean_up
    func_new $2

elif [ "$1" = "-d" ] && [ -n "$2" ]; then
    read -p "Are you sure you want to $(tput setaf 124)delete this$(tput sgr0) symlink? ($(tput setaf 124)y$(tput sgr0)/n) " confirm
    if [ "$confirm" = "y" ]; then
        func_delete $@
    fi
    func_clean_up

elif [ "$1" = "-d" ]; then
    read -p "Are you sure you want to $(tput setaf 124)delete all$(tput sgr0) files in the mktmp directory? ($(tput setaf 124)y$(tput sgr0)/n) " confirm
    if [ "$confirm" = "y" ]; then
        rm -rf "$HOME/.cache/mktmp"
        mkdir -p "$HOME/.cache/mktmp"
        touch "$HOME/.cache/mktmp/config"

    fi
    func_clean_up

elif [ "$1" = "-f" ]; then
    func_clean_up
    func_follow $@

elif [ "$1" = "-l" ]; then
    func_clean_up
    func_list $@

elif [ "$1" = "-c" ]; then
    echo "Cleaning up the config file..."
    func_clean_up

elif [ "$1" = "-h" ]; then
    func_help

else
    echo "$(tput setaf 124)Invalid option. Use $(tput sgr0)-h$(tput setaf 124) for help.$(tput sgr0)"
    func_help

fi
