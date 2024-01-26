#!/bin/bash
#Asks for the pcap file name with extension
echo "Enter pcap file name: "

#Checks whether the pcap file exists
read pcapFile

#If pcap file exists
if [ -f $pcapFile ]; then

	#Check and install xxd if not installed
	if ! command -v xxd &> /dev/null; then
		echo "#-#-#-#-Updating Repo and Installing xxd for HEX to ASCII Conversion-#-#-#-#"
		sudo apt-get update;sudo apt-get -y install xxd;
	fi
	
	#Check and install tshark if not installed
	if ! command -v tshark &> /dev/null; then
		echo "#-#-#-#-Updating Repo and Installing xxd for HEX to ASCII Conversion-#-#-#-#"
		sudo apt-get update;sudo apt-get -y install tshark;
	fi
	
	#Export DNS query name where [protocol=DNS] AND [destination IP = 192.168.157.145] as pcapDNSDetails
	tshark -Y "dns and ip.dst == 192.168.157.145" -T fields -e "dns.qry.name" -r $pcapFile > pcapDNSDetails
	
	#Removing the first 9 bytes from each line as they are related to the command & control communication, not the data
	cat pcapDNSDetails | awk 'sub(/^.{18}/,"")' > output.txt
	
	#Removing the ".microsofto365.com" domain name
	sed -i 's/.microsofto365.com//' output.txt
	
	#Removing all the [.] fullstops
	sed -i "s/\.//" output.txt
	
	#Convert output from HEX to humanreadable
	cat output.txt | xxd -r -p > hexDecodedOutput.txt
	echo -e "\nhexDecodedOutput.txt Has Been Generated!"
	
	#Remove unwanted files
	rm -rf pcapDNSDetails output.txt
else
	echo -e "\nFile $pcapFile Does Not Exist!"
fi
