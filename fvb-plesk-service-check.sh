#!/bin/bash
# shellcheck source=/dev/null
##########################################################################################################################
# Autor: Falk von Broen <info@it-fvb.de>
# Internet: https://it-fvb.de
# Version: 1.0.3
# Daten letzter Änderungen: 2018-06-06
##########################################################################################################################

# Diesem Skript über Konsole als root Ausführungsrechte geben: chmod +x fvb-plesk-service-check.sh
# Cronjob in Plesk unter Tools & Einstellungen --> Geplante Aufgaben --> mit 5-Minuten-Intervall einrichten: */5 * * * *

# Allgemeines zur verwendeten Plesk service CLI
# https://docs.plesk.com/en-US/onyx/cli-linux/using-command-line-utilities/service-services.40786/

# Auflistung aller verfügbaren Servies mit Statuscode (0=läuft nicht, 1=läuft, -1=deaktiviert)
# plesk bin service --list -format "\n%s\t%k"

# Definition aller Services die überprüft und bei gestopptem Status wieder gestartet werden sollen (mit Leerzeichen Servicenamen trennen)
serviceArray=(plesk web smtp imap-pop3 dns spamassassin milter nginx fail2ban php-fpm plesk-php56-fpm plesk-php70-fpm plesk-php71-fpm plesk-php72-fpm)

# Administrator E-Mail - Hier werden Benachrichtigungen verschickt, wenn ein Service nicht korrekt läuft
adminEmail="your@admin-mail-adress.tld"
# Betreff der E-Mail an den Administrator
adminSubject="Host: $(hostname -f) - Service ausgefallen" # z. B. Host: it-fvb.de - Service ausgefallen

###############################!!! Ab hier Programmcode - nichts mehr verändern !!!#######################################
##########################################################################################################################
# Funktion um den StatusCode eines Services zu ermitteln
getServiceStatus() {
    serviceName=$1;
    statusCode=$(/usr/sbin/plesk bin service --list -include $serviceName -format "%s");
    printf "$statusCode"; # Ausgabe = Rückgabe an Funktionsaufrufer
    # return $statusCode # Kann bei Aufruf nur abgefangen werden, wenn man in nächster Zeile bei Aufruf mit $? die Rückgabe abfrägt / ausgibt
}

# Abarbeitung des Scripts
printf "Starte Überprüfung der Services...\n"

# Schleife für Prüfung aller Services aus dem serviceArray
for service in "${serviceArray[@]}"
do
    # StatusCode von Service ermitteln
    statusCode=$(getServiceStatus ${service}) # $(funktionsAufruf Parameter) leitet die Ausgabe in die Variable um

    # Prüfung der möglichen StatusCodes und reagieren darauf
    case $statusCode in
        1) # Service läuft - StatusCode: 1
            printf "OK: ${service} läuft\n"
        ;;
        0) # Service läuft nicht - StatusCode: 0
            printf "ERROR: ${service} läuft nicht - Service wird neu gestartet...\n"

            # Versuch den Service neu zu starten
            /usr/sbin/plesk bin service --restart ${service}

            # Überprüfung, ob Service-Neustart erfoglreich war
            if [ "$(getServiceStatus ${service})" = "1" ]; then
                printf "OK: ${service} konnte erfolgreich wieder gestartet werden...\n"

                # Mail an Administrator versenden
                { printf "Folgender Service ist ausgefallen, konnte aber erfolgreich wieder gestartet werden:\n\n"; printf "Ausgefallener Service: ${service}\nStatusCode: $statusCode\n\n"; printf "Datum & Uhrzeit: $(date +"%Y-%m-%d %H:%M:%S")"; } | sed 's/^/  /g' | mailx -s "$adminSubject" $adminEmail
            else
                printf "FATAL ERROR: ${service} konnte nicht wieder gestartet werden...\n"

                # Mail an Administrator versenden
                { printf "Folgender Service ist ausgefallen, Neustart blieb erfolglos:\n\n"; printf "Ausgefallener Service: ${service}\nStatusCode: $statusCode\n\n"; printf "Datum & Uhrzeit: $(date +"%Y-%m-%d %H:%M:%S")\n\n"; printf "!!! Manuelle Überprüfung nötig !!! Service konnte nicht neu gestartet werden !!!"; } | sed 's/^/  /g' | mailx -s "$adminSubject" $adminEmail
            fi
        ;;
        -1) # Service ist deaktiviert und kann nicht gestartet werden (manuelle Prüfung notwendig) - StatusCode: -1
            printf "ERROR: ${service} ist deaktiviert und kann nicht gestartet werden (manuelle Prüfung notwendig)\n"

            # Mail an Administrator versenden
            { printf "Folgender Service ist ausgefallen, Neustart blieb erfolglos, weil deaktiviert:\n\n"; printf "Ausgefallener Service: ${service}\nStatusCode: $statusCode\n\n"; printf "Datum & Uhrzeit: $(date +"%Y-%m-%d %H:%M:%S")\n\n"; printf "!!! Manuelle Überprüfung nötig !!!"; } | sed 's/^/  /g' | mailx -s "$adminSubject" $adminEmail
        ;;
        *) # Default - Unbekannter Status-Code wurde vom Service ermittelt - StatusCode: irgendwas, also nicht 1, 0 oder -1
            printf "FATAL ERROR: ${service} - Unbekannter StatusCode: $statusCode\n"

            # Mail an Administrator versenden
            { printf "Folgender Service ist ausgefallen - unbekannter StatusCode:\n\n"; printf "Ausgefallener Service: ${service}\nStatusCode: $statusCode\n\n"; printf "Datum & Uhrzeit: $(date +"%Y-%m-%d %H:%M:%S")\n\n"; printf "!!! Manuelle Überprüfung nötig !!!"; } | sed 's/^/  /g' | mailx -s "$adminSubject" $adminEmail
        ;;
    esac
done

# Script abgearbeitet
printf "Service Überprüfung erfolgreich abgeschlossen.\n"
