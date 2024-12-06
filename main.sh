#!/bin/bash

source ./mapping.sh
source ./gNMI.sh
source ./CLI.sh

gnmi_path=$1
echo "Path: $1"
gnmi=$(CallGNMI $gnmi_path)

if [[ $? -eq 0 ]]; then
    echo -e "GNMI Output: \n$gnmi"
else
    echo "Error Path doesnt exit"
    exit 1
fi

CliCommPathAll=$(CallCLIPath "$gnmi_path")
## here we need to add a loop to parse at the , take the command put it in the folder 
for CliCommPath in ; do
    if [[ $? -eq 0 ]]; then
        echo "CLI Command: $CliCommPath"
        CLI=$(CallCLI $CliCommPath)
        if [[ $? -eq 0 ]]; then
            echo -e "CLI Output: \n$CLI"
        else
            echo "Error Path doesnt exit"
            exit 1
        fi
    else
        echo "Error Path doesnt exit"
        exit 1
    fi
done 


