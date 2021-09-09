# suitecrm-shell-installer
A useful shell script for people who want to deploy SuiteCRM in a web server

Do you want to install SuiteCRM on your web server but don't want to have the hassle to do a manual installation? So this shell script is for you! Avoid errors and or a bad installation!

What you need to use this:
1) Download the script on your web server
2) Execute the script using sudo ./install_suitecrm.sh

What this script will do:

1) Clone the official repository of SuiteCRM (https://github.com/salesagility/SuiteCRM)
2) Move the files to the informed directory on your web server
3) Assign the needed permissions and owners on folder/files
4) Guide you step by step through the creation of the configuration file
5) In the end, will perform a quiet install on your server, and SuiteCRM is ready to use!

I created this script based on my experience with SuiteCRM and extra information available on the official documentation

Enjoy!
