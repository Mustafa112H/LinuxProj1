#!/bin/bash
###Mohammad Omar 1221332 section 2
###Heba Mustafa 1221916 section 3
###Dr. Khader Mohammad
source ./mapping.sh
source ./gNMI.sh
source ./CLI.sh

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
if [ $counter -gt 1 ];then
    echo -e "\n\nEach CLI command provides a subset of the values in the gNMI output,
    allowing complete coverage for a thorough comparison."
fi

##COMPARING
newGnmi=$(echo "$gnmi" | tr -d '"{}] '|tr -s ',' '\n')
CLIFULL=$(echo "$CLIFULL" | tr -d '" '| tr -s ',' '\n')
echo "$newGnmi" > new_gnmi.txt
echo "$CLIFULL" > cli.txt
sed -i '/\[/d' new_gnmi.txt
sed -i '/^$/d' new_gnmi.txt
sed -i '/^$/d' cli.txt
echo -e "\n\n\n\n The CLI is: \n$(cat cli.txt) \n\n\n The GNMI: \n$(cat new_gnmi.txt)"

diff new_gnmi.txt cli.txt > comp.txt

# Check the exit status of diff
if [ $? -eq 0 ]; then
    echo -e "\n\nAll values match; no discrepancies."
    exit 0
fi

newGnmiNorm=$(echo "$newGnmi" | tr -s [A-Z] [a-z] | tr -d "_\n")
CLIFULLNorm=$(echo "$CLIFULL" | tr -s [A-Z] [a-z] | tr -d "_\n")

if [ $newGnmiNorm == $CLIFULLNorm ]; then
    echo -e "\n\nMatch After Normalization."
    exit 0
fi
##bytes G KB=2^10 = 1024 MB GB M K


file="comp.txt"
first_line=$(sed -n '1p' "$file")

if [[ "$first_line" =~ [0-9]+c[0-9]+ ]]; then
    key=$(sed -n '2p' "$file" | cut -d':' -f1 | sed 's/< //')
    value_gnmi=$(sed -n '2p' "$file" | cut -d':' -f2)
    value_cli=$(sed -n '4p' "$file" | cut -d':' -f2)
    if [[ $value_cli == *"G"* ]];then
        echo -e "\n\nConverting to Match......"
        value_cli=$(echo "$value_cli" | tr -d " ><G")
        value_gnmi=$(echo "$value_cli" | tr -d " ><G")
        value_cli=$(( value_cli * 1000000000 ))
        value_gnmi=$(( value_gnmi * 1000000 ))
    fi
    if [[ $value_cli == *"M"* ]];then
        echo -e "\n\nConverting to Match......"
        value_cli=$(echo "$value_cli" | tr -d " ><M")
        value_gnmi=$(echo "$value_cli" | tr -d " ><M")
        value_cli=$(( value_cli * 1000000 ))
        value_gnmi=$(( value_gnmi * 1000000 ))
    fi
    if [[ $value_cli == *"K"* ]];then
        echo -e "\n\nConverting to Match......"
        value_cli=$(echo "$value_cli" | tr -d " ><K")
        value_gnmi=$(echo "$value_cli" | tr -d " ><K")
        value_cli=$(( value_cli * 1000 ))
        value_gnmi=$(( value_gnmi * 1000000 ))
    fi

        key="Values"
        if [ $value_cli == $value_gnmi ];then
            echo -e "\n\n Successfully Matched after Conversion"
            exit 0
        fi

        value_cli=$value_cli" bps"
        value_gnmi=$value_gnmi" bps"
    fi
    #if integer and CLIPathAll contains speed than integer * M

    echo -e "\n\n$key differs, showing \"$value_gnmi\" in gNMI and \"$value_cli\" in CLI output."
    exit 0
fi

if [[ $first_line =~ ^[0-9]+d[0-9]+$ ]]; then
    # Extract the key before : from the second line
    key=$(sed -n '2p' "$file" | cut -d':' -f1 | sed 's/< //')
    echo -e "\n\n$key is present in the gNMI output but missing in the CLI output."
    exit 0
fi
