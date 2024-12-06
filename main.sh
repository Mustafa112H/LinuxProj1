#!/bin/bash

source ./mapping.sh
gnmi_path=$1
cli_commands=$(CallCLI "$gnmi_path")

if [[ $? -eq 0 ]]; then
    echo "CLI Command: $cli_commands"
else
    echo "Error Path doesnt exit"
    exit 1
fi
