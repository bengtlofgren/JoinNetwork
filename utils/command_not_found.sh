#!/bin/bash

# Function to check if a command is available
command_exists() {
    local path=$(which "$1")
    # check if path is actually a path
    if [ -n "$path" ] && [ -f "$path" ]; then
        return true
    fi
    return false
}

# Check if wget is installed
wget_exists(){
    if command_exists wget; then
    echo "wget is already installed."
    else
    # Check if Homebrew is installed
    if command_exists brew; then
        echo "Homebrew is already installed. Installing wget..."
        brew install wget
    else
        echo "Homebrew is not installed. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Check if Homebrew installation was successful
        if [ $? -eq 0 ]; then
        echo "Homebrew installation successful. Installing wget..."
        brew install wget
        else
        echo "Error: Homebrew installation failed. Unable to install wget."
        exit 1
        fi
    fi
    fi
}