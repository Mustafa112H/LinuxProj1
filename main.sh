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


CLIFULL=""
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
tempPath=$(echo "$CliCommPathAll" | tr ' ' '*')
counter=0
echo -e "\nCLI Command(s): "
for CliCommPath in $(echo "$tempPath" | tr ',' ' '); do
    CliCommPathIn=$(echo "$CliCommPath" | tr '*' ' ')
    ((counter++))
    echo -e "\nCommand $counter: $CliCommPathIn"
    CLI=$(CallCLI "$CliCommPathIn")
    echo -e "CLI Output: \n$CLI"
    CLIFULL+="$CLI,"
done




##COMPARING
newGnmi=$(echo "$gnmi" | tr -d '"{}]_ '|tr 'A-Z' 'a-z'| tr -s ',' '\n')
CLIFULL=$(echo "$CLIFULL" | tr -d '_" '|tr 'A-Z' 'a-z'| tr -s ',' '\n')
echo "$newGnmi" > new_gnmi.txt
echo "$CLIFULL" > cli.txt
sed -i '/\[/d' new_gnmi.txt
sed -i '/^$/d' new_gnmi.txt
echo -e "\n\n\n\n The CLI is: \n$(cat cli.txt) \n\n\n The GNMI: \n$(cat new_gnmi.txt)"

diff new_gnmi.txt cli.txt > comp.txt

# Check the exit status of diff
if [ $? -eq 0 ]; then
    echo -e "\n\nAll values match; no discrepancies."
    exit 0
fi

# for lineG in $(<new_gnmi.txt); do
#     for lineC in $(<cli.txt); do
#     echo "$line"  
# done