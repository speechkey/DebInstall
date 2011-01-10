#Compress files and send it to i
#archiveAndSendToI.sh <archivename> <folder name on i> [files]
echo $@
	for x in "$#-2"
	do	
		if [ -e $x ]
		then
			if [ -e $1 ]
			then
				tar rf $1 $x
			else
				tar cf $1 $x
			fi	
		else
			echo -e "\033[40m\033[31mERROR. File $2 not exists.\033[0m"
		fi
	done
	
	gzip $1
	
	if [ $? -eq 0 ] && [ -e "$1.gz"	]
	then
		scp "$1.gz" "i:~/$2"
	else
		echo -e "\033[40m\033[31mERROR. File $2 not exists.\033[0m"
	fi	
