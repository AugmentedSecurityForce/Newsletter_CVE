#!/bin/bash

# ==============================================================================
# Script Name       : newsletter_CVE.sh
# Author            : Julien GARCIA
# Creation Date     : 2024-05-22
# Version           : 1.0
# Last Update       : [Date of last update]
# Description       : This script automates the retrieval of CVEs for different vendors and concatenates the results into one or more JSON files. It then sends an email with the JSON file as an attachment.
# Usage             : ./auto_CVE.sh
# Dependencies      : Make sure the 'cvemap' script is present and executable.
# History           :
#                     - [Date] : [Description of update]
#                     - [Date] : [Description of update]
# Remarks           :
#                     - This script requires bash, jq, and sendmail.
#                     - Vendors are listed in lowercase.
# ==============================================================================

# Function to get the date in YYYYMMDD format
get_current_date() {
    date +"%Y%m%d"
}

# List of vendors in lowercase
# If needed, search for your vendor from: https://www.cvedetails.com/vendor-search.php
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

# Iterate over each vendor
for vendor in "${vendors[@]}"
do
    # Convert the vendor to lowercase
    lowercase_vendor=$(echo "$vendor" | tr '[:upper:]' '[:lower:]')
    
    # Current date in YYYYMMDD format
    current_date=$(get_current_date)
    
    # Directory name for the current date
    directory="${current_date}"
    
    # Check if the directory exists, if not, create it
    if [ ! -d "$directory" ]; then
        mkdir "$directory"
    fi
    
    # Full path to the JSON file
    json_filename="${directory}/${current_date}_${lowercase_vendor}.json"
    
    # Replace the placeholder with the current vendor and add the -json option with the filename
    command="./cvemap -vendor \"$lowercase_vendor\" -fe 'template' -f kev -age '< 31' -json > \"$json_filename\""
    
    # Display the command with the replaced vendor
    echo "Command with \"$vendor\":"
    echo "$command"
    echo "--------------------"
    
    # Execute the command using eval
    eval "$command"
done

# Concatenate all JSON files into one file "all_YYYYMMDD.json"
# Output filename
output_json_filename="${directory}/all_${current_date}.json"

# Concatenate all JSON files into one file
cat "${directory}"/*.json > "$output_json_filename"

# Display confirmation message
echo "JSON files concatenated into ${output_json_filename}"

# Send email with JSON file as attachment
recipient="service-it@domain.tld"
sender="noreply@domain.tld"
subject="Newsletter CVE"
body="Please find attached the JSON file containing the CVEs."

# Command to send email
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

# Display confirmation message for email sending
echo "Email sent to $recipient with attachment $output_json_filename"