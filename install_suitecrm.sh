#!/bin/bash

#Maintainer: Ricardo Baptista <github dot com slash ex0ticOne>

#Some variables that will be used during the script
repository=github
maintainer=salesagility
appname=suitecrm
gitsource=https://$repository.com/$maintainer/$appname.git
zipsource=https://$repository.com/$maintainer/$appname/archive/refs/heads/master.zip

#Asks the user if the server meets the requirements before starting the installation
echo ""
echo "SERVER REQUIREMENTS TO RUN SUITECRM PROPERLY"
echo ""
echo "PHP 5.6, 7.0, 7.1, 7.2, 7.3, 7.4"
echo "Apache 2.2 or 2.4"
echo "MariaDB 5.5, 10, 10.1, 10.2, 10.3"
echo "MySQL 5.5, 5.6, 5.7 8"
echo "SQL Server 2008+"
echo ""
echo "Does your server meets these requirements?"
read -p "Answer 'y' (yes) / 'n' (no): " meets_server_requirements

	case "$meets_server_requirements" in
	
	y | Y)
	echo "OK, proceeding to the installation"
	sleep 2
	;;
	
	n | N)
	echo "Install the missing requirements with your package manager and run this script again"
	echo "Exiting in 5 seconds"
	sleep 5
	exit
	;;
	
	* )
	echo "Invalid answer, exiting"
	sleep 5
	exit
 	;;
	
	esac

#Asks the user if the server has the git package
echo "This script uses the 'git' package to get the SuiteCRM files. "
echo "Does your server have this package installed?"
read -p "Answer 'y' (yes) / 'n' (no): " meets_script_requirements

	case "$meets_script_requirements" in
	
	y | Y)
	echo "OK, proceeding to the installation"
	#Clones the official repository
	git clone $gitsource
	echo "Repository cloned with success"
	echo "Starting the deployment of SuiteCRM"
	echo ""
	sleep 2
	;;
	
	n | N)
	#If the user doesn't have git on the server, uses an alternative method
	echo "No problem, using 'cURL' as an alternative method to get the files from the repository"
	curl -LO $zipsource
	
	#Renames the downloaded .zip
	mv master.zip $appname.zip
	
	#Extract the files using unzip
	unzip -q $appname.zip
	mv 'SuiteCRM-master' $appname
	;;
	
	* )
	echo "Invalid answer, exiting"
	sleep 5
	exit
 	;;
	
	esac

##Asks for the path
echo "-------------------------------------------------------------------"
echo "IMPORTANT QUESTION, ANSWER WITH ATTENTION!"
echo ""
echo "What's the path that you want to install SuiteCRM?" 
echo ""
echo "Normally it's the root directory ('/') or a subdirectory ('/www-data' or '/www', for example)."
echo "If you are unsure, check with your web server admin or hosting company, especially if there's something already installed in your server."
echo ""
echo "Choosing an inappropriate path may result in breaking other applications installed on your server."
echo "-------------------------------------------------------------------"
echo ""
read -p "Answer (start and end the path with a '/'): " _installpath
	
#Asks for the username that the web server runs under
echo "-------------------------------------------------------------------"
echo "ANOTHER IMPORTANT QUESTION!"
echo ""
echo "What's the username that you web server runs under?"
echo ""
echo "Normally it's 'www-data', 'apache' or 'nobody'." 
echo "If you are unsure, check with your web server admin or hosting company."
echo "-------------------------------------------------------------------"
echo ""
read -p "Username: " _apacheusername

read -p "Group assigned to this user (normally it's $_apacheusername too, but may be different depending on how your server was configured): " _apachegroup

#Move the files from the extracted source to the installation destination
echo "Moving the files to the informed destination ($_installpath$appname)"
sleep 5
mv $appname $_installpath
echo "Files moved with success"
sleep 5

#Asks the user if he wants to change the folder name
read -p "Do you want to change the folder name? If you are happy with 'suitecrm', don't type anything and just hit enter to continue " appname
if [ -z "$appname" ]
then
    #Maintains the folder name if the user is ok with the default folder name
    appname=suitecrm
else
	#Changes the parent folder name according to the new folder name defined by the user
	mv $_installpath'suitecrm' $_installpath$appname
fi

#Goes to the installation folder
cd $_installpath$appname

#Creates the missing cache folder
mkdir -p cache
echo "Cache folder created"

#Assigns the folder structure to the username that the web server runs under
echo "A sudo is needed to change owners and permissions on the folder structure. This is mandatory to install SuiteCRM properly. "
sudo chown -R $_apacheusername:$_apachegroup $_installpath$appname
echo "Setting the username that the web server runs under ($_apacheusername) as the owner of the entire SuiteCRM folder structure"
sleep 5

#Changes permissions of some folders to allow the conclusion of the installation
sudo chmod -R 775 cache custom modules themes data upload
echo "Changing permissions on some folders to install SuiteCRM without any problems"
sleep 5

#Creates a empty custom config file and assign the permission. 
#This file will be written when executing the installation wizard and can be used to modify your configuration in the future without breaking anything.
touch config_override.php
sudo chmod 775 config_override.php 2>/dev/null
echo "Creating a custom config file to be used in the future (config_override.php)."

#Starts the configuration process
echo "-------------------------------------------------------------------"
echo "SETTING YOUR SUITECRM INSTALLATION"
echo "-------------------------------------------------------------------"
echo "Now that you have all the SuiteCRM stack in your server, it's time to configure your installation. "
echo "When answering, if you are ok with the suggested default value (when available), just hit enter and that will be considered in your final config file. "

#Prompt the user for the currency
read -p "Currency on ISO 4217 format, (Default is 'USD'): " currency_iso4217
	if [ -z "$currency_iso4217" ]
then
    #If the user doesn't answer anything, sets the default value
    currency_iso4217='USD'
fi

#Currency config
read -p "Currency name (Default is 'US Dollar'): " currency_name
	if [ -z "$currency_name" ]
then
    #If the user doesn't answer anything, sets the default value
    currency_name='US Dollar'
fi

read -p "Currency digits on cents (Default is '2'): " currency_digits
	if [ -z "$currency_digits" ]
then
    #If the user doesn't answer anything, sets the default value
    currency_digits=2
fi

read -p "Currency Symbol (Default is '\$'): " currency_symbol
	if [ -z "$currency_symbol" ]
then
    #If the user doesn't answer anything, sets the default value
    currency_symbol=\$
fi

#Date, formatting and local standards
read -p "Date format (Default is 'Y-m-d'): " date_format
	if [ -z "$date_format" ]
then
    #If the user doesn't answer anything, sets the default value
    date_format='Y-m-d'
fi

read -p "Decimal seperator (Default is ','): " date_seperator
	if [ -z "$date_seperator" ]
then
    #If the user doesn't answer anything, sets the default value
    date_seperator=,
fi

read -p "Export Charset (Default is 'ISO-8859-1'): " export_charset
	if [ -z "$export_charset" ]
then
    #If the user doesn't answer anything, sets the default value
    export_charset='ISO-8859-1'
fi

read -p "Language (Default is 'en_us'): " language
	if [ -z "$language" ]
then
    #If the user doesn't answer anything, sets the default value
    language='en_us'
fi

read -p "Locale name format (Default is 's f l'): " locale_name_format
	if [ -z "$locale_name_format" ]
then
    #If the user doesn't answer anything, sets the default value
    locale_name_format='s f l'
fi

read -p "Number grouping seperator (Default is ','): " number_grouping_seperator
	if [ -z "$number_grouping_seperator" ]
then
    #If the user doesn't answer anything, sets the default value
    number_grouping_seperator=,
fi

read -p "Time format (Default is 'H:i'): " time_format
	if [ -z "$time_format" ]
then
    #If the user doesn't answer anything, sets the default value
    time_format='H:i'
fi

read -p "Delimiter (Default is ','): " delimiter
	if [ -z "$delimiter" ]
then
    #If the user doesn't answer anything, sets the default value
    delimiter=,
fi

#Database connection
echo "-------------------------------------------------------------------"
echo "DATABASE CONFIGURATION"
echo "-------------------------------------------------------------------"
echo "Now it's time to set the database credentials. Pay attention to this, take your time to configure this properly."
echo "Passwords don't output to the terminal when typing for security reasons."
echo "Check the keys you're pressing and your keyboard layout to avoid problems with a incorrect password. "
echo ""
read -s -p "Database Admin Password: " db_admin_password

read -s -p "Repeat the Database Admin Password: " db_admin_password_check

#Check the password for the database
while [ "$db_admin_password" != "$db_admin_password_check" ] 
do
	echo "Password mismatch, let's set again"
	read -s -p "Database Admin Password: " db_admin_password
	
	read -s -p "Repeat the Database Admin Password: " db_admin_password_check
	
done

read -p "Database Admin User Name: " db_admin_user_name
read -p "Database Name: " db_database_name
read -p "Database Host Name: " db_host_name
read -p "Database Type (Default is 'mysql'): " db_type
	if [ -z "$db_type" ]
then
    #If the user doesn't answer anything, sets the default value
    db_type='mysql'
fi

#Admin account configuration
read -s -p "Site Admin Password: " site_admin_password

read -s -p "Repeat Site Admin Password: " site_admin_password_check

#Check the password for the site admin
while [ "$site_admin_password" != "$site_admin_password_check" ] 
do
	echo "Password mismatch, let's set again"
	read -s -p "Site Admin Password: " site_admin_password
	
	read -s -p "Repeat Site Admin Password: " site_admin_password_check
	
done

read -p "Site Admin User Name: " site_admin_user_name
read -p "Site Name: " site_url
read -p "System Name: " system_name

#Create config_si.php for the silent installer with the user's inputs
echo "<?php
\$sugar_config_si  = array (
    'dbUSRData' => 'create',
    'default_currency_iso4217' => '$currency_iso4217',
    'default_currency_name' => '$currency_name',
    'default_currency_significant_digits' => '$currency_digits',
    'default_currency_symbol' => '$currency_symbol',
    'default_date_format' => '$date_format',
    'default_decimal_seperator' => '$decimal_seperator',
    'default_export_charset' => '$export_charset',
    'default_language' => '$language',
    'default_locale_name_format' => '$locale_name_format',
    'default_number_grouping_seperator' => '$number_grouping_seperator',
    'default_time_format' => '$time_format',
    'export_delimiter' => '$delimiter',
    'setup_db_admin_password' => '$db_admin_password',
    'setup_db_admin_user_name' => '$db_admin_user_name',
    'setup_db_create_database' => 1,
    'setup_db_database_name' => '$db_database_name',
    'setup_db_drop_tables' => 0,
    'setup_db_host_name' => '$db_host_name',
    'setup_db_pop_demo_data' => false,
    'setup_db_type' => '$db_type',
    'setup_db_username_is_privileged' => true,
    'setup_site_admin_password' => '$site_admin_password',
    'setup_site_admin_user_name' => '$site_admin_user_name',
    'setup_site_url' => '$site_url',
    'setup_system_name' => '$system_name',
  );" > config_si.php

#Shows the created config_si.php on the terminal"
cat config_si.php

#Asks for confirmation on the settings
read -p "Are you sure you want these settings? Answer 'Y' (yes) to install SuiteCRM or 'N' (no) to edit the config file: " confirm_settings
	case $confirm_settings in
		Y | y )
		#Executes the silent installer using PHP
		echo "Starting install.php script to finish the SuiteCRM deployment. If this fails, go to 'example.com/$appname/install.php?goto=SilentInstall'"
		sleep 5
		php -r "\$_SERVER['HTTP_HOST'] = 'localhost'; \$_SERVER['REQUEST_URI'] = 'install.php';\$_REQUEST = array('goto' => 'SilentInstall', 'cli' => true);require_once 'install.php';";
		;;
		
		N | n )
		#Opens the config_si.php in autosave mode to allow modification before running install.php
		echo "Opening config_si.php to allow changes"
		sleep 2
		nano -t "config_si.php"
		#Executes the silent installer using PHP, just like the 'Yes' option
		echo "Starting install.php script to finish the SuiteCRM deployment. If this fails, go to 'example.com/$appname/install.php?goto=SilentInstall'"
		sleep 5
		php -r "\$_SERVER['HTTP_HOST'] = 'localhost'; \$_SERVER['REQUEST_URI'] = 'install.php';\$_REQUEST = array('goto' => 'SilentInstall', 'cli' => true);require_once 'install.php';";
		;;
		
		* )
		echo "Starting install.php script to finish the SuiteCRM deployment. If this fails, go to 'example.com/$appname/install.php?goto=SilentInstall'"
		sleep 5
		#Executes the silent installer using PHP
		echo "Starting install.php script to finish the SuiteCRM deployment"
		php -r "\$_SERVER['HTTP_HOST'] = 'localhost'; \$_SERVER['REQUEST_URI'] = 'install.php';\$_REQUEST = array('goto' => 'SilentInstall', 'cli' => true);require_once 'install.php';";
		
		;;
		
	esac
