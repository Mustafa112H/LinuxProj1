#!/bin/bash
###Mohammad Omar 1221332 section 2
###Heba Mustafa 1221916 section 3
###Dr. Khader Mohammad
###Eng. Ahed Mafarjeh
source ./mapping.sh
source ./gNMI.sh
source ./CLI.sh
##this will be used to combine the full CLI 
CLIFULL=""
##this will be used to figure out the number commands
counter=0
##this will be used to take the path from terminal 
gnmi_path=$1

echo "Path: $1"
##calls the function from the gnmi.sh file and takes the gnmi command and puts it in this var
gnmi=$(CallGNMI $gnmi_path)
##if the command was success print the gnmi command
if [[ $? -eq 0 ]]; then
    echo -e "GNMI Output: \n$gnmi"
else
    echo "Error Path doesnt exit"
    exit 1
fi
##calls the function that will get the Cli path from the mapping
CliCommPathAll=$(CallCLIPath "$gnmi_path")
## here we need to add a loop to parse at the , take the command put it in the folder
##since we may have more than one cli command mapped from the gnmi path 
##in order to loop through each command we can remove the white spaces and place * so we can loop word by word 
tempPath=$(echo "$CliCommPathAll" | tr ' ' '*')
echo -e "\nCLI Command(s): "
##loop word by word where , is turned into a whitespace making each command a word
for CliCommPath in $(echo "$tempPath" | tr ',' ' '); do
##reinsert the whitespaces
    CliCommPathIn=$(echo "$CliCommPath" | tr '*' ' ')
    ((counter++))
    ##print the command Cli
    echo -e "\nCommand $counter: $CliCommPathIn"
    ##call the command from cli.txt
    CLI=$(CallCLI "$CliCommPathIn")
    echo -e "CLI Output: \n$CLI"
    ##add them all into one string(all the cli command outputs)
    CLIFULL+="$CLI,"
done
##if counter is more than one that means we combined a subset of commands
if [ $counter -gt 1 ];then 
    echo -e "\n\nEach CLI command provides a subset of the values in the gNMI output,
    allowing complete coverage for a thorough comparison."
fi

##COMPARING
##clean the outputs
newGnmi=$(echo "$gnmi" | tr -d '"{}] '|tr -s ',' '\n')
CLIFULL=$(echo "$CLIFULL" | tr -d '" '| tr -s ',' '\n')
##place the ouputs into files for comparison
echo "$newGnmi" > new_gnmi.txt
echo "$CLIFULL" > cli.txt
##clean the files remove any lines that are empty or have a subset of values like adjacent 
sed -i '/\[/d' new_gnmi.txt
sed -i '/^$/d' new_gnmi.txt
sed -i '/^$/d' cli.txt
##echo -e "\n\n\n\n The CLI is: \n$(cat cli.txt) \n\n\n The GNMI: \n$(cat new_gnmi.txt)"
##this will check the difference between the two files and return the difference on a file called comp.txt
diff new_gnmi.txt cli.txt > comp.txt

#if match then print match and stop 
if [ $? -eq 0 ]; then
    echo -e "\n\nAll values match; no discrepancies."
    exit 0
fi
##Normalize turn the upcase to lower and remove __ and see if they match
newGnmiNorm=$(echo "$newGnmi" | tr -s [A-Z] [a-z] | tr -d "_\n")
CLIFULLNorm=$(echo "$CLIFULL" | tr -s [A-Z] [a-z] | tr -d "_\n") 
##if match after normalization then stop 
if [ $newGnmiNorm == $CLIFULLNorm ]; then
    echo -e "\n\nMatch After Normalization."
    exit 0
fi
 
file="comp.txt"
##take the first line in comp which will give us a key to then difference 
first_line=$(sed -n '1p' "$file")
#this will give us the line number of the line containing ---
line_number=$(sed -n '/---/=' "$file")
##takes the first problem from the cli.txt
line_number=$((line_number + 1))
##takes first problem in the gnmi.txt (problem: unmatched output)
second=$(sed -n '2p' "$file")
##line after ---
afterPattern=$(sed -n "${line_number}p" "$file") 
##while unmatched values still exist
while [[ (-n $second && $second != "---") || $second == "---" && -n "$afterPattern" ]]; do 
    #this means there exists something in cli.txt that doesnt exist in gnmi
    if [[ $second == "---" ]]; then
    #take the key and say it doesnt exist then go to the next case by reinitializing the values and removing the
    ##lines that we have already compared
        key2=$(sed -n "${line_number}p" "$file" | cut -d':' -f1 | tr -d " ><")
        echo -e "\n\n$key2 is present in the CLI output but missing in the gNMI output."
        sed -i '2d' $file
        line_number=$(sed -n '/---/=' "$file")
        line_number=$((line_number + 1)) 
        sed -i "${line_number}d" "$file" 
        second=$(sed -n '2p' "$file")
        line_number=$(sed -n '/---/=' "$file")
        line_number=$((line_number + 1))
        afterPattern=$(sed -n "${line_number}p" "$file")
        continue
    fi

    ##if the start of the file contains d that means we have lines that exist in gnmi but dont in cli
    if [[ $first_line =~ [0-9]+d[0-9]+ || -z $afterPattern ]]; then
        # Extract the key before : from the second line
        key=$(sed -n '2p' "$file" | cut -d':' -f1 | tr -d " ><")
        echo -e "\n\n$key is present in the gNMI output but missing in the CLI output."
        sed -i '2d' $file
        ##reinitialize to see next difference 
        line_number=$(sed -n '/---/=' "$file")
        line_number=$((line_number + 1)) 
        sed -i "${line_number}d" "$file" 
        second=$(sed -n '2p' "$file")
        line_number=$(sed -n '/---/=' "$file")
        line_number=$((line_number + 1))
        afterPattern=$(sed -n "${line_number}p" "$file")
        continue
    fi 
    ##if the start of the file conatins a then exists in cli and not in gnmi
    if [[ $first_line =~ [0-9]+a[0-9]+ ]]; then
        # Extract the key before : from the second line
        key=$(sed -n '2p' "$file" | cut -d':' -f1 | tr -d " ><")
        echo -e "\n\n$key is present in the CLI output but missing in the gNMI output."
        sed -i '2d' $file
        line_number=$(sed -n '/---/=' "$file")
        line_number=$((line_number + 1))
        sed -i "${line_number}d" $file 
        second=$(sed -n '2p' "$file")
        line_number=$(sed -n '/---/=' "$file")
        line_number=$((line_number + 1))
        afterPattern=$(sed -n "${line_number}p" "$file")
        continue
    fi 
    ##changes in the lines is formatted ad number c number 
    if [[ "$first_line" =~ [0-9]+c[0-9]+ ]]; then
    #take the keys of the lines facing each of other and if they dont equal each other than we say key doesnt equal key 
        if [[ "$second" == *":"* ]]; then
            key=$(sed -n '2p' "$file" | cut -d':' -f1 |  tr -d " ><")
            key2=$(sed -n "${line_number}p" "$file" | cut -d':' -f1 | tr -d " ><")
            if [[ $key != $key2 ]]; then
                echo -e "\n\n\"$key\" is present in Gnmi but is called \"$key2\" in Cli"
                sed -i '2d' $file
                line_number=$(sed -n '/---/=' "$file")
                line_number=$((line_number + 1))
                sed -i "${line_number}d" $file 
                second=$(sed -n '2p' "$file")
                line_number=$(sed -n '/---/=' "$file")
                line_number=$((line_number + 1))
                afterPattern=$(sed -n "${line_number}p" "$file")    
                continue 
            fi 
        fi
        ##else take the values so we can compare the values of the keys 
        value_gnmi=$(sed -n '2p' "$file" | cut -d':' -f2|tr -d "< >" ) 
        value_cli=$(sed -n "${line_number}p" "$file" | cut -d':' -f2 |tr -d "< >" )
        ##start unit comparisons and fix the values
        ##if B then turn it into bytes
        if [[ $value_cli == *"GB"* ]];then
            echo -e "\n\nUnit Conversion Handling......"
            value_cli=$(echo "$value_cli" | tr -d " ><GB")
            value_gnmi=$(echo "$value_gnmi" | tr -d " ><")
            value_cli=$(awk "BEGIN {print $value_cli  1000000000 * 1073741824}")
            if [[ $decimal_cli -gt 4 ]]; then
                value_cli=$(( value_cli + 1 ))
            fi 
            decimal_gnmi=$(echo "$value_gnmi" | grep -o "\.[0-9]" | cut -d"." -f2)
            if [[ $decimal_gnmi -gt 4 ]]; then
                value_gnmi=$(( value_gnmi + 1 ))
            fi 
            value_cli=$value_cli"bytes"
            if [[ "$second" != *":"* ]]; then
                key="Values"
            fi 
        fi
        if [[ $value_cli == *"MB"* ]];then
            echo -e "\n\nUnit Conversion Handling......"
            value_cli=$(echo "$value_cli" | tr -d " ><MB")
            value_gnmi=$(echo "$value_gnmi" | tr -d " ><")
            value_cli=$(awk "BEGIN {print $value_cli  1000000 * 1048576 }")
            if [[ $decimal_cli -gt 4 ]]; then
                value_cli=$(( value_cli + 1 ))
            fi 
            decimal_gnmi=$(echo "$value_gnmi" | grep -o "\.[0-9]" | cut -d"." -f2)
            if [[ $decimal_gnmi -gt 4 ]]; then
                value_gnmi=$(( value_gnmi + 1 ))
            fi 
            value_cli=$value_cli"bytes"
            if [[ "$second" != *":"* ]]; then
                key="Values"
            fi  
        fi
        if [[ $value_cli == *"KB"* ]];then
            echo -e "\n\nUnit Conversion Handling......"
            value_cli=$(echo "$value_cli" | tr -d "><KB")
            value_gnmi=$(echo "$value_gnmi" | tr -d " ><")
            value_cli=$(awk "BEGIN {print $value_cli * 1024}")
            decimal_cli=$(echo "$value_cli" | grep -o "\.[0-9]" | cut -d"." -f2)
            if [[ $decimal_cli -gt 4 ]]; then
                value_cli=$(( value_cli + 1 ))
            fi 
            decimal_gnmi=$(echo "$value_gnmi" | grep -o "\.[0-9]" | cut -d"." -f2)
            if [[ $decimal_gnmi -gt 4 ]]; then
                value_gnmi=$(( value_gnmi + 1 ))
            fi 
            value_cli=$value_cli"bytes"
            if [[ "$second" != *":"* ]]; then
                key="Values"
            fi  
        fi
        ##check if they equal each other after converting
        if [[ "$value_cli" == "$value_gnmi" ]];then
            echo -e "\n\n Successfully Matched after Conversion" 
            sed -i '2d' $file
            line_number=$(sed -n '/---/=' "$file")
            line_number=$((line_number + 1))
            sed -i "${line_number}d" $file 
            second=$(sed -n '2p' "$file")
            line_number=$(sed -n '/---/=' "$file")
            line_number=$((line_number + 1))
            afterPattern=$(sed -n "${line_number}p" "$file")
            continue
        fi
        
        ##converting (not bytes) normal conversions 
        if [[ $value_cli == *"G"* ]];then
            echo -e "\n\nUnit Conversion Handling......"
            value_cli=$(echo "$value_cli" | tr -d " ><G")
            value_gnmi=$(echo "$value_gnmi" | tr -d " ><")
            value_cli=$(( value_cli * 1000000000 ))
            value_gnmi=$(( value_gnmi * 1000000 ))
            if [[ $decimal_cli -gt 4 ]]; then
                value_cli=$(( value_cli + 1 ))
            fi 
            decimal_gnmi=$(echo "$value_gnmi" | grep -o "\.[0-9]" | cut -d"." -f2)
            if [[ $decimal_gnmi -gt 4 ]]; then
                value_gnmi=$(( value_gnmi + 1 ))
            fi 
            value_cli=$value_cli"bps"
            value_gnmi=$value_gnmi"bps"
            if [[ "$second" != *":"* ]]; then
                key="Values"
            fi  
        fi

        if [[ $value_cli == *"M"* ]];then
            echo -e "\n\nUnit Conversion Handling......"
            value_cli=$(echo "$value_cli" | tr -d " ><M")
            value_gnmi=$(echo "$value_gnmi" | tr -d " ><")
            value_cli=$(( value_cli * 1000000 ))
            value_gnmi=$(( value_gnmi * 1000000 ))
            if [[ $decimal_cli -gt 4 ]]; then
                value_cli=$(( value_cli + 1 ))
            fi 
            decimal_gnmi=$(echo "$value_gnmi" | grep -o "\.[0-9]" | cut -d"." -f2)
            if [[ $decimal_gnmi -gt 4 ]]; then
                value_gnmi=$(( value_gnmi + 1 ))
            fi 
            value_cli=$value_cli"bps"
            value_gnmi=$value_gnmi"bps"
            if [[ "$second" != *":"* ]]; then
                key="Values"
            fi 
        fi

        if [[ $value_cli == *"K"* ]];then
            echo -e "\n\nUnit Conversion Handling......"
            value_cli=$(echo "$value_cli" | tr -d " ><K")
            value_gnmi=$(echo "$value_gnmi" | tr -d " ><")
            value_cli=$(( value_cli * 1000 ))
            value_gnmi=$(( value_gnmi * 1000000 ))
            if [[ $decimal_cli -gt 4 ]]; then
                value_cli=$(( value_cli + 1 ))
            fi 
            decimal_gnmi=$(echo "$value_gnmi" | grep -o "\.[0-9]" | cut -d"." -f2)
            if [[ $decimal_gnmi -gt 4 ]]; then
                value_gnmi=$(( value_gnmi + 1 ))
            fi 
            value_cli=$value_cli"bps"
            value_gnmi=$value_gnmi"bps"
            if [[ "$second" != *":"* ]]; then
                key="Values"
            fi  
        fi

         ###compare and see    
        if [[ "$value_cli" == "$value_gnmi" ]];then
            echo -e "\n\n Successfully Matched after Conversion" 
            sed -i '2d' $file
            line_number=$(sed -n '/---/=' "$file")
            line_number=$((line_number + 1))
            sed -i "${line_number}d" $file 
            second=$(sed -n '2p' "$file")
            line_number=$(sed -n '/---/=' "$file")
            line_number=$((line_number + 1))
            afterPattern=$(sed -n "${line_number}p" "$file")
            continue
        fi
        ##Percision Handling
        ##here we need to make sure we are dealing with numbers that have only one . since if it had more it may be an ip etc 
        #also remove the % and compare
        ##round the decimals to closest value
        period_countcli=$(echo "$value_cli" | grep -o "\." | wc -l) 
        period_countgnmi=$(echo "$value_gnmi" | grep -o "\." | wc -l) 
        if [[ $period_countcli -eq 1 || $period_countgnmi -eq 1 || $value_gnmi == *"%"* || $value_cli == *"%"* ]]; then 
            decimal_cli=$(echo "$value_cli" | grep -o "\.[0-9]" | cut -d"." -f2|tr -d "%")
            decimal_gnmi=$(echo "$value_gnmi" | grep -o "\.[0-9]" | cut -d"." -f2|tr -d "%")
            value_cli=$(echo "$value_cli" | cut -d'.' -f1|tr -d " <>")
            value_gnmi=$(echo "$value_gnmi" | cut -d'.' -f1| tr -d " <>")

            if [[ $decimal_cli -gt 4 ]]; then
                value_cli=$(( value_cli + 1 ))
            fi 
            if [[ $decimal_gnmi -gt 4 ]]; then
                value_gnmi=$(( value_gnmi + 1 ))
            fi 
                echo -e "Percision Handling.........." 
        fi

        if [[ "$value_cli" == "$value_gnmi" ]];then
            echo -e "\n\nSuccessfully matched after adjusting percision"
            sed -i '2d' $file
            line_number=$(sed -n '/---/=' "$file")
            line_number=$((line_number + 1))
            sed -i "${line_number}d" $file
            second=$(sed -n '2p' "$file") 
            line_number=$(sed -n '/---/=' "$file")
            line_number=$((line_number + 1))
            afterPattern=$(sed -n "${line_number}p" "$file")
            continue
        fi
        ##lastly if the values differn even after the handling that means they are different 
        echo -e "\n\n$key differs, showing \"$value_gnmi\" in gNMI and \"$value_cli\" in CLI output."

        sed -i '2d' $file
        line_number=$(sed -n '/---/=' "$file")
        line_number=$((line_number + 1))    
        sed -i "${line_number}d" $file 
        second=$(sed -n '2p' "$file")
        line_number=$(sed -n '/---/=' "$file")
        line_number=$((line_number + 1))
        afterPattern=$(sed -n "${line_number}p" "$file")
        continue
    fi
done


