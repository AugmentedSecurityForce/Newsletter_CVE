#!binbash

# Nom du script  check_thursday.sh
# Vérifie si aujourd'hui est le jeudi suivant le deuxième mardi du mois

# Obtenir le jour actuel, le mois et l'année
today=$(date +%d)
month=$(date +%m)
year=$(date +%Y)

# Trouver la date du deuxième mardi du mois
second_tuesday=$(date -d $year-$month-01 +1 week +1 day +$(date -d $year-$month-01 +%u) days +%d)

# Calculer la date du jeudi suivant le deuxième mardi
second_tuesday_date=$year-$month-$second_tuesday
next_thursday=$(date -d $second_tuesday_date +2 days +%d)

# Si aujourd'hui est ce jeudi, exécuter le script Nom_Du_Script.sh
if [ $today -eq $next_thursday ]; then
    chemin_vers_newsletter_cve.sh
fi