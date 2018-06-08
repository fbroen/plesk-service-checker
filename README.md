# Plesk service check shell script for use as cronjob
View README better formated: https://fbroen.github.io/plesk-service-checker/

More useful posts from me on my blog: https://it-fvb.de/blog/

I developed this shell script for Linux operating systems with Plesk so that I can regularly check certain services automatically via a cron job.

If a service fails, which should not happen normally, but sometimes happens, then this cron job ensures that the service is restarted and a mail is sent to the administrator.

In the mail, the administrator receives information about the status of the service that has failed and whether this service could be restarted by this script.

## Installation & How to use

### Preparations
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

### Check if script is working...

Execute as root in your console:

./fvb-plesk-service-check.sh

### Ad script to your cron task list in Plesk

Log in to Plesk as an administrator.

Go to: Tools & Settings -> Scheduled Tasks -> Add Task

Task type: execute command

Command: /var/www/vhosts/fvb-plesk-service-check.sh

Run: Cron style

Right next to cron style: * / 5 * * * *

System user: root

Description: Plesk Service Checker

Notify: Only errors

Have fun...
