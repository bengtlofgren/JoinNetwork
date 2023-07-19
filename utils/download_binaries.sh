#!/bin/sh

# Download the binaries
download_namada_binaries(){
    # Function takes one argument: the version of the binaries to download
    # Example: download_namada_binaries 0.1.0
    # The binaries will be downloaded to a folder called namada_binaries in the current directory
    # The binaries will be downloaded from the github release page
    # The binaries will be downloaded for the current operating system and architecture

    # Check if the version is provided
    if [ -z "$1" ]
    then
        echo "Please provide the version of the binaries to download in the format x.y.z"
        exit 1
    fi

    # Check if the version is valid
    if ! [ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]
    then
        echo "Please provide a valid version of the binaries to download in the format x.y.z"
        exit 1
    fi

    NAMADA_VERSION="$1"

    # Check which operating system is being used
    if [ "$(uname)" = "Darwin" ]
    then
        # Mac OS X
        OS="Darwin"
    elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]
    then
        # GNU/Linux
        OS="Linux"
    else
        echo "Unsupported operating system"
        exit 1
    fi

    # Check which architecture is being used
    if [ "$(uname -m)" = "x86_64" ]
    then
        # 64-bit
        ARCH="amd64"
    elif [ "$(uname -m)" = "armv7l" ]
    then
        # ARMv7
        ARCH="armv7"
    elif [ "$(uname -m)" = "arm64" ]
    then
        # ARM64
        ARCH="arm64"
    else
        echo "Unsupported architecture"
        exit 1
    fi

    # Create the folder to download the binaries to
    mkdir -p namada_binaries

    # Download the binaries
    # TODO: Add support for other architectures

    # Check that wget is installed
    $SCRIPT_DIR/utils/command_not_found.sh
    wget_exists
    if [ ! command_exists wget ]; then
        echo "wget is not installed. Please install wget and try again."
        exit 1
    fi

    # Download the binaries
    wget https://github.com/anoma/namada/releases/download/v${NAMADA_VERSION}/namada-v${NAMADA_VERSION}-${OS}-x86_64.tar.gz
    
    # Extract the binaries
    tar -xzf namada-v${NAMADA_VERSION}-${OS}-x86_64.tar.gz -C namada_binaries

    # Remove the tar.gz file
    rm -f namada-v${NAMADA_VERSION}-${OS}-x86_64.tar.gz

    # Move the binaries to the namada_binaries folder
    mv namada_binaries/namada-v${NAMADA_VERSION}-${OS}-x86_64/namada* namada_binaries

    # Remove the folder that was created
    rm -rf namada_binaries/namada-v${NAMADA_VERSION}-${OS}-x86_64

    # Make the binaries executable
    chmod +x namada_binaries/*

    # Add the binaries to the PATH
    export PATH=$PATH:$(pwd)/namada_binaries

    # Check if the binaries are in the PATH
    if ! command -v namada &> /dev/null
    then
        echo "The binaries failed to be added to PATH"
        exit 1
    fi

    echo "Would you like to add the binaries to the PATH permanently? (y/n)"
    read -p "Recommended is (y):" ADD_TO_PATH

    if [ "$ADD_TO_PATH" = "y" ]
    then
        # Add the binaries to the PATH permanently
        echo "This will prompt your password in order to access your PATH variable"
        sudo cp namada_binaries/* /usr/local/bin
    fi

    # Check that namada has installed successfully by checking that the binaries are in the namada_binaries folder
    if [ ! -f namada_binaries/namada ]
    then
        echo "namada failed to install"
        exit 1
    fi

}

download_cometbft_binaries(){
    set -Eo pipefail
    CMT_MAJORMINOR="0.37"
    CMT_PATCH="2"

    CMT_REPO="https://github.com/cometbft/cometbft"

    CMT_VERSION="${CMT_MAJORMINOR}.${CMT_PATCH}"

    TARGET_PATH="/usr/local/bin"
    TMP_PATH="/tmp"

    error_exit()
    {
        echo "Error: $1" >&2
        exit 1
    }

    # check for existence
    CMT_EXECUTABLE=$(which cometbft)
    if [ -x "$CMT_EXECUTABLE" ]; then
    CMT_EXISTS_VER=$(${CMT_EXECUTABLE} version)
    fi

    if [ $CMT_EXISTS_VER == "${CMT_MAJORMINOR}" ]; then
    echo "cometbft already exists in your current PATH with a sufficient version = $CMT_EXISTS_VER"
    echo "cometbft is located at = $(which cometbft)"
    exit
    fi

    read -r SYSTEM MACHINE <<< "$(uname -s -m)"

    ARCH="amd64"
    if [ $MACHINE = "aarch64" ] || [ $MACHINE = "arm64" ]; then
    ARCH="arm64"
    fi

    RELEASE_URL="${CMT_REPO}/releases/download/v${CMT_VERSION}/cometbft_${CMT_VERSION}_$(echo "${SYSTEM}" | tr '[:upper:]' '[:lower:]')_${ARCH}.tar.gz"
    echo "$RELEASE_URL"

    curl -LsSfo "$TMP_PATH"/cometbft.tar.gz "$RELEASE_URL" || error_exit "cometbft release download failed"

    sudo tar -xvzf $TMP_PATH/cometbft.tar.gz cometbft || error_exit "cometbft release extraction failed"

    rm $TMP_PATH/cometbft.tar.gz

    # Add the binaries to the PATH
    export PATH=$PATH:$TARGET_PATH



    # Check if the binaries are in the PATH
    if ! command -v cometbft &> /dev/null
    then
        echo "The binaries failed to be added to PATH"
        exit 1
    fi

    echo "Would you like to add the binaries to the PATH permanently? (y/n)"
    read -r ADD_TO_PATH

    if [ "$ADD_TO_PATH" = "y" ]
    then
        # Add the binaries to the PATH permanently
        echo "This will prompt your password in order to access your PATH variable"
        sudo cp $(which cometbft) /usr/local/bin
    fi

    echo "cometbft successfully installed"
}