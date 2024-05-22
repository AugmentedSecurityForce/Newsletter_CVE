#!binbash

# ==============================================================================
# Script Name       : check_thursday.sh
# Description       : Checks if today is the Thursday following the second Tuesday of the month.
# Usage             : Execute this script to check if today is the appropriate Thursday to run another script.
# Dependencies      : None
# Author            : [Julien Garcia]
# Creation Date     : [22/05/2024]
# Version           : 1.0
# ==============================================================================

# Get the current day, month, and year
today=$(date +%d)
month=$(date +%m)
year=$(date +%Y)

# Find the date of the second Tuesday of the month
second_tuesday=$(date -d $year-$month-01 +1 week +1 day +$(date -d $year-$month-01 +%u) days +%d)

# Calculate the date of the Thursday following the second Tuesday
second_tuesday_date=$year-$month-$second_tuesday
next_thursday=$(date -d $second_tuesday_date +2 days +%d)

# If today is this Thursday, execute the script Nom_Du_Script.sh
if [ $today -eq $next_thursday ]; then
    path_to_newsletter_cve.sh
fi
