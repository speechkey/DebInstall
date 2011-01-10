#!/bin/bash
#Call script with following arguments: installTestPackages <fulllogfile> <shortlogfile>

#Uninstall deb package with dpkg --purge, write dpkg output in log file and last uninstall status in lastUninstallStatus variable.
#Call function with following arguments: purgeDeb <package.deb> <logfile>
purgeDeb () {

	if [ "${1##*.}" == 'deb' ]
	then
		packageName=${1##*/}
		packageName=${packageName%%_*}
		
		dpkg --purge $packageName &>>$2
		
		if [ $? -eq 0 ]
		then
			echo -e "\033[40m\033[32m$1 has been uninstalled successfully.\033[0m" >> $2
			echo "--------------------------------------------------------------------" >> $2
			lastUninstallStatus=0
		else
			echo -e "\033[40m\033[35mERROR. Fail to uninstall $1.\033[0m" >> $2
			echo "--------------------------------------------------------------------" >> $2
			lastUninstallStatus=1
		fi
	fi
}

#Install deb package with dpkg, write dpkg output in log and last install status in lastInstallStatus variable.
#Call function with following arguments: installDeb <package.deb> <logfile> 
installDeb () {
	if [ "${1##*.}" == 'deb' ]
	then
		dpkg -i $1 &>>$2
		
		if [ $? -eq 0 ]
		then
			echo -e "\033[40m\033[33m$1 has been installed successfully.\033[0m" >> $2
			echo "--------------------------------------------------------------------" >> $2
			lastInstallStatus=0
		else
			echo -e "\033[40m\033[31mERROR. Fail to install $1.\033[0m" >> $2
			echo "--------------------------------------------------------------------" >> $2
			lastInstallStatus=1
		fi
	fi
}

for masterPackage in ${PWD}/*.deb
do
	installDeb $masterPackage $1
	masterName=${masterPackage##*/}

	for slavePackage in ${PWD}/*.deb
	do
		slaveName=${slavePackage##*/}

		#If master package hasn't been installed break slave loop.

		#Exclude master package from slavePackage Arrays
		if [ "$masterPackage" != "$slavePackage" ]
		then
			if [ $lastInstallStatus -eq 1 ]
			then
				echo -e "\033[40m\033[31mMaster: $masterName - fail\033[0m" >> $2
				break
			else
				echo -e "\033[40m\033[33mMaster: $masterName - success\033[0m" >> $2
				
				installDeb $slavePackage $1
			
#If last slave package installed successfully, remove him and master package and install master package again.
				if [ "$lastInstallStatus" -eq 0 ]
				then
					echo -e "\033[40m\033[33mSlave: $slaveName - success\033[0m" >> $2 
					purgeDeb $slavePackage $1
					purgeDeb $masterPackage $1
					installDeb $masterPackage $1
				else
					echo -e "\033[40m\033[31mSlave: $slaveName - fail\033[0m" >> $2
					lastInstallStatus=0
				fi
			fi
		fi
		echo '-------------------------------------------------------------' >> $2
	done
	
	purgeDeb $masterPackage $1
	echo '=====================================================================' >> $1
	echo '=====================================================================' >> $2
done
