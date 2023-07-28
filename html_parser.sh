#!/bin/bash

LGREEN="\e[1;92m"
WHITEBOLD="\e[1;97m"
LRED="\e[91m"
LCYAN="\e[96m"
LYELLOW="\e[1;93m"
RED="\e[31m"
END="\e[0m"

if [ "$1" = "" ]
then
	echo "Wrong use"
	echo "$0 google.com"
	exit
fi

print_sep() {
	local message=${#1}+4
	local separator=""

	for((i=0; i<message; i++));do
		separator="${separator}-"
	done
	echo -e "\t\t${WHITEBOLD}${separator}${END}"
}

echo ""
echo -e "\t\t${LGREEN}=================================="
echo -e "\t\t  #### Nitczi's HTML_PARSER ####"
echo -e "\t\t==================================${END}\n"
echo -e "${WHITEBOLD}Analysing the domain...${END}"


download=$(wget -q -4  $1 -O $1-font.txt) 
echo "File downloaded to analysis... $1-font.txt"
sleep 2
echo "Aplying some filters..."
sleep 2

files=$(grep "href" $1-font.txt | cut -d"/" -f3 | grep '\.' | cut -d'"' -f1 | cut -d"'" -f1 | cut -d"?" -f1 | cut -d":" -f1 | sed 's/www.//'| sed '/^$/d'| egrep ".com|.br|.gov|.net|.org" | sort | uniq)

echo

phrase="These were the domains/subdomains founded"
print_sep "$phrase"
echo -e "\t\t  ${LRED}$phrase${END}"
print_sep "$phrase"

for fin in $files:
do
	filtred=$(echo $fin | sed 's/://')
	echo -e "\t\t\t$filtred"
done
print_sep "$phrase"

echo -e "\nResolving hosts founded"

echo -ne '#####                               (20%)\r'
sleep 1
echo -ne '############                        (40%)\r'
sleep 1
echo -ne '##################                  (57%)\r'
sleep 1
echo -ne '######################              (68%)\r'
sleep 1
echo -ne '############################        (83%)\r'
sleep 1
echo -ne '####################################(100%)\r'
echo -ne '\n'



echo
echo -e "${WHITEBOLD}=======================================================================================${END}"
echo -e "\t\t\t\t${LRED}Host Resolved"
echo -e "${WHITEBOLD}=======================================================================================${END}"

print_sep "$phrase"
echo -e "\t\t\t\t${LRED} A REGISTERS${END}"
print_sep "$phrase"


# A registers
for A_reg in $files:
do
	trated=$(echo $A_reg |sed "s/://")
	domain=$(host -t A $trated | grep -v "IPv6" | grep "has address")
	resolved=$(host -t A $trated | grep -v "IPv6" | grep "has address")
	if [ -n "$domain" ]
	then
		while read -r line
		do
			filt=$(echo $line | cut -d" " -f1)
			ip=$(echo $line | cut -d" " -f4)
			echo -e "\t\t${LCYAN}$filt${END} -> ${LYELLOW}$ip${END}"
		done <<< "$domain"
	else
		continue
	fi
done
echo

print_sep "$phrase"
echo -e "\t\t\t\t${LRED} MX REGISTERS${END}"
print_sep "$phrase"

# MX registres
for MX_reg in $files:
do
        trated=$(echo $MX_reg |sed "s/://")
        domain=$(host -t MX $trated | grep -v "IPv6" | grep "mail is handled by")
        resolved=$(host -t MX $trated | grep -v "IPv6" | grep "mail is handled by")
	error=$(host -t MX $trated | grep -v "IPv6" | grep "has no MX record")

	if [ -n "$domain" ]
	then
		while read -r line; do
			filt=$(echo $line | cut -d" " -f1)
			mail=$(echo $line | cut -d" " -f7)	
			echo -e "\t\t${LCYAN}$filt${END} -> ${LYELLOW}$mail${END}"
		done <<< "$domain"
	elif [ -n "$error" ]
	then
		echo -e "\t\t\t    ${RED}No MX were found.${END}"
		continue
	fi
done
echo
