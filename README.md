# Plesk service check shell script for use as cronjob
View README better formated: https://fbroen.github.io/plesk-service-checker/

Dieses Shell-Script für Linux-Betriebssysteme mit Plesk wurde von mir entwickelt, damit automatisch über einen Cronjob regelmäßig bestimmte Dienste geprüft werden können.

Wenn ein Dienst ausfällt, was normalerweise nicht vorkommen sollte, jedoch ab und zu vorkommt, dann sorgt dieser Cronjob dafür, dass der Dienst wieder gestartet wird und eine Mail an den Administrator verschickt wird.

In der Mail erhält der Administrator Informationen zum Status des Dienstes der ausgefallen ist und ob dieser Dienst durch dieses Skript wieder gestartet werden konnte.

##Installation & How to use

###Preparations
Download the file "fvb-plesk-service-check.sh" from this repository and save it to your server.

Open the script in an editor, eg. For example, enter nano or vim and enter the administrator's e-mail address for the adminEmail variable.

In the variable serviceArray all services are listed separated by blanks, which should be checked by script and automatically restarted in case of failure.

Because there are different services running on each server with Plesk, it is recommended that you issue the following command from the console with root access to see all services:

plesk bin service --list -format "\n%s\t%k"

The console lists all installed services. Only the services that have the status code "1" should be entered in the variable serviceArray so that they can be restarted if necessary.

As a storage location for the script on the server, I recommend the following directory:

/var/www/vhosts/

Afterwards the execution rights have to be given to the script (as root):

chmod +x fvb-plesk-service-check.sh

###Check if script is working...

Execute as root in your console:

./fvb-plesk-service-check.sh

###Ad script to your cron task list in Plesk

