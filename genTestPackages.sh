#!/usr/bin/env bash
#Generate debs test control file archive.
#Call with following arguments: genDebControl <Package> <Name> <Version> 
genDebControl () {
	echo -e "---> Generating control file for \033[40m\033[33mPackage: $1, Name: $2, Version: $3\033[0m."
echo -e "Package: $1
Name: $2
Version: $3
Architecture: iphoneos-arm
Description: This is sample Description.
Homepage: http://irepository.net
Maintainer: gremoz@gremoz.net
Author: gremoz@gremoz.net
Sponsor: http://irepository.net
Section: iRepository
Depiction: http://irepository.net" > control
if [ -e control ]
then
	echo '---> Control file has bin written successfully.'
	echo '---> Archiving control file.'
	tar czf control.tar.gz control
	if [ -e control.tar.gz ] && [ $? -eq 0 ]
	then
		echo -e "---> Control file has bin archived \033[40m\033[33msuccessfully.\033[0m"
		rm -f control
	else
		echo -e "\033[40m\033[31m---> ERROR.\033[0m Fail to archive control file."
	fi
fi 
}

#Generate two types of debs data file archive for test package.
#Call with following arguments genDebData <"different"|"same">
genDebData () {
	if [ "$1" == "different" ] && [ "$PWD" != "/" ]
	then
		echo "---> Creating content of $1 package."
		mkdir -p etc/diffPackage
		echo 'This is different package.' > etc/diffPackage/diffFile
		
		if [ -e etc/diffPackage/diffFile ]
		then
			echo "---> Content of $1 package was written successfully."
			echo "---> Creating content of $1 package."
			tar czf data.tar.gz etc
			if [ -e data.tar.gz ] && [ $? -eq 0 ]
			then
				echo -e "---> Data file of \033[40m\033[33m$1 package\033[0m has been generated \033[40m\033[33msuccessfully\033[0m."
				rm -Rf etc
			else
				echo -e "\033[40m\033[31m--->ERROR.\033[0m Fail to create data file of $1 package."
			fi
		fi
	else
		echo "---> Creating content of $1 package."
		mkdir -p etc/testPackage
		echo 'This is a test package.' > etc/testPackage/testFile
		
		if [ -e etc/testPackage/testFile ]
		then
			echo "---> Content of $1 package was written successfully."
			echo "---> Creating content of $1 package."
			tar czf data.tar.gz etc
			if [ -e data.tar.gz ] && [ $? -eq 0 ]
			then
				echo -e "---> Data file of \033[40m\033[33m$1 package\033[0m has been generated \033[40m\033[33msuccessfully\033[0m."
				rm -Rf etc
			else
				echo -e "\033[40m\033[31m--->ERROR.\033[0m Fail to create data file of $1 package."
			fi
		fi
	fi
}

#Create debian-binary file if not exists
if [ ! -e debian-binary ]
then
	echo '2.0' > debian-binary 
fi
for package in testPackage diffPackage
do
	for name in testName diffName
	do
		for version in 1.04 2.05
		do
			for packageType in different same
			do
				genDebControl $package $name $version
				genDebData $packageType
				if [ -e data.tar.gz ] && [ -e control.tar.gz ] && [ -e debian-binary ]
				then
					ar rc ${package}_${name}_${version}_${packageType}.deb debian-binary control.tar.gz data.tar.gz
					if [ -e ${package}_${name}_${version}_${packageType}.deb ] && [ $? -eq 0 ]
					then
						echo -e "---> Package \033[40m\033[33m${package}_${name}_${version}_${packageType}.deb\033[0m has been generated \033[40m\033[33msuccessfully\033[0m."
						rm -f control.tar.gz data.tar.gz
					else
						echo -e "---> \033[40m\033[31mERROR.\033[0m Fail to generate ${package}_${name}_${version}_${packageType}.deb package."
					fi
				fi
			done
		done
	done
done
