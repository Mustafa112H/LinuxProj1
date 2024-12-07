# #!/bin/bash

# source ./mapping.sh
# source ./gNMI.sh
# source ./CLI.sh
# touch GOut.sh
# touch Cout.sh

# gnmi_path=$1
# echo "Path: $1"
# gnmi=$(CallGNMI $gnmi_path)

# if [[ $? -eq 0 ]]; then
#    echo $gnmi > Gout.sh
#     echo -e "GNMI Output: \n$gnmi" 
# else
#     echo "Error Path doesnt exit"
#     exit 1
# fi

# CliCommPathAll=$(CallCLIPath "$gnmi_path")
# ## here we need to add a loop to parse at the , take the command put it in the folder 
# # Split the comma-separated string into an array
# tempPath=$(echo "$CliCommPathAll" | tr ' ' '*')
# for CliCommPath in $(echo "$tempPath" | tr ',' ' '); do
#     CliCommPathIn=$(echo "$CliCommPath" | tr '*' ' ')
#     echo "CLI Command: $CliCommPathIn"
#     CLI=$(CallCLI "$CliCommPathIn")
#     echo -e "CLI Output: \n$CLI"
# done 

# ###COMPARING












#!/bin/bash

source ./mapping.sh
source ./gNMI.sh
source ./CLI.sh
touch Gout.sh
touch Cout.sh
touch new_gnmi.txt
touch cli.txt


total_cli_commands_output=""
counter=0


gnmi_path=$1
echo "Path: $1"
gnmi=$(CallGNMI $gnmi_path)

if [[ $? -eq 0 ]]; then
   echo $gnmi > Gout.sh
    echo -e "GNMI Output: \n$gnmi"
else
    echo "Error Path doesnt exit"
    exit 1
fi

CliCommPathAll=$(CallCLIPath "$gnmi_path")
## here we need to add a loop to parse at the , take the command put it in the folder
# Split the comma-separated string into an array
tempPath=$(echo "$CliCommPathAll" | tr ' ' '*')
counter=0
for CliCommPath in $(echo "$tempPath" | tr ',' ' '); do
    CliCommPathIn=$(echo "$CliCommPath" | tr '*' ' ')
    echo "CLI Command: $CliCommPathIn"
    CLI=$(CallCLI "$CliCommPathIn")
    echo -e "CLI Output: \n$CLI"
    total_cli_commands_output+="$CLI"
    ((counter++))
done


#echo "total_cli_commands_output =$total_cli_commands_output"






##COMPARING

#case1 All values match; no discrepancies
if [[ $counter -eq 1 ]]; then

newGnmi=$(echo "$gnmi" | tr -d '"' | tr -d '}' | tr -s ',' '\n')

echo "$newGnmi" > new_gnmi.txt
echo "$CLI" > cli.txt

if diff -q new_gnmi.txt cli.txt; then
  echo "All values match; no discrepancies."
else
  echo "test the other cases"
fi

rm new_gnmi.txt cli.txt

#case2  : Each CLI command provides a subset of the values in the gNMI output, allowing complete coverage for a thorough comparison.

else
newGnmi=$(echo "$gnmi" | tr -d '"' | tr -d '}' | tr -s ',' '\n')

echo "$newGnmi" > new_gnmi.txt
echo "$CLI" > total_cli_commands_output.txt

if diff -q new_gnmi.txt total_cli_commands_output.txt; then
  echo "Each CLI command provides a subset of the values in the gNMI output, allowing complete coverage for a thorough comparison."
else
  echo "test the other cases"
fi

rm new_gnmi.txt cli.txt
fi






















