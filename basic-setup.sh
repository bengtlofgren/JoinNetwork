#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Access the command_exists function
. $SCRIPT_DIR/ledger_commands.sh

echo "This will setup a bunch of keys and addresses for you to use in the tutorial"
basic_init
