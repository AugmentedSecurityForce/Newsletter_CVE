#!/bin/bash

# ==============================================================================
# Nom du Script    : newsletter_CVE.sh
# Auteur           : Julien GARCIA
# Date de création : 22/05/2024
# Version          : 1.0
# Mise à jour      : [Date de la dernière mise à jour]
# Description      : Ce script automatise la récupération des CVE pour différents 
#                    vendors et concatène les résultats dans un ou plusieurs fichiers JSON.
#                    Il envoie ensuite un email avec le fichier JSON en pièce jointe.
# Usage            : ./auto_CVE.sh
# Dépendances      : Assurez-vous que le script 'cvemap' est présent et exécutable.
# Historique       :
#                   - [Date] : [Description de la mise à jour]
#                   - [Date] : [Description de la mise à jour]
# Remarques        :
#                   - Ce script nécessite bash, jq, et sendmail.
#                   - Les vendors sont listés en minuscules.
# ==============================================================================

# Fonction pour obtenir la date au format YYYYMMDD
get_current_date() {
    date +"%Y%m%d"
}

# Liste des vendors en minuscules
# Au besoin, chercher votre vendeur depuis : https://www.cvedetails.com/vendor-search.php
vendors=(
    fortinet
    checkpoint
    paloaltonetworks
    cisco
    stormshield
    f5
    php
    apache
    microsoft
)

# Parcourir chaque vendor
for vendor in "${vendors[@]}"
do
    # Convertir le vendor en minuscules
    lowercase_vendor=$(echo "$vendor" | tr '[:upper:]' '[:lower:]')
    
    # Date du jour au format YYYYMMDD
    current_date=$(get_current_date)
    
    # Nom du répertoire pour la date actuelle
    directory="${current_date}"
    
    # Vérifier si le répertoire existe, sinon le créer
    if [ ! -d "$directory" ]; then
        mkdir "$directory"
    fi
    
    # Nom du fichier JSON avec chemin complet
    json_filename="${directory}/${current_date}_${lowercase_vendor}.json"
    
    # Remplacer le placeholder par le vendor actuel et ajouter l'option -json avec le nom de fichier
    command="./cvemap -vendor \"$lowercase_vendor\" -fe 'template' -f kev -age '< 31' -json > \"$json_filename\""
    
    # Afficher la commande avec le vendor remplacé
    echo "Commande avec \"$vendor\":"
    echo "$command"
    echo "--------------------"
    
    # Exécuter la commande avec eval
    eval "$command"
done

# Concaténer tous les fichiers JSON dans un seul fichier "all_YYYYMMDD.json"
# Nom du fichier de sortie
output_json_filename="${directory}/all_${current_date}.json"

# Concaténation de tous les fichiers JSON dans un seul fichier
cat "${directory}"/*.json > "$output_json_filename"

# Afficher le message de confirmation
echo "Fichiers JSON concaténés dans ${output_json_filename}"

# Envoi de l'email avec le fichier JSON en pièce jointe
recipient="service-it@domain.tld"
sender="noreply@domain.tld"
subject="Newsletter CVE"
body="Veuillez trouver ci-joint le fichier JSON contenant les CVE."

# Commande pour envoyer l'email
(
    echo "From: $sender"
    echo "To: $recipient"
    echo "Subject: $subject"
    echo "MIME-Version: 1.0"
    echo "Content-Type: multipart/mixed; boundary=\"FILEBOUNDARY\""
    echo
    echo "--FILEBOUNDARY"
    echo "Content-Type: text/plain"
    echo
    echo "$body"
    echo
    echo "--FILEBOUNDARY"
    echo "Content-Type: application/json; name=\"all_${current_date}.json\""
    echo "Content-Disposition: attachment; filename=\"all_${current_date}.json\""
    echo "Content-Transfer-Encoding: base64"
    echo
    base64 "$output_json_filename"
    echo
    echo "--FILEBOUNDARY--"
) | sendmail -t

# Afficher le message de confirmation de l'envoi de l'email
echo "Email envoyé à $recipient avec la pièce jointe $output_json_filename"
