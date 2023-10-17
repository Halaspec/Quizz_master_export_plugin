#!/bin/bash

# PHASE 1 RECUPERER LA DATA DEPUIS LE SERVEUR
# Database connection parameters
DB_HOST="10.0.10.22"
DB_USER="root"
DB_PASS="hLEDAiM13F"
DB_NAME="prixplaisir"
OUTPUT_FILE="data.txt"
BLUE='\033[0;34m'
NC='\033[0m' # No Color
# SQL query to execute
SQL_QUERY="select quiz_results from wp_mlw_results ;;"

# Execute SQL query and save the result to CSV file
mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e"$SQL_QUERY" -P "30363" --batch --raw > "$OUTPUT_FILE"

(grep -o -P 'user_answer".*?s:[0-9]+:"[a-zA-Z]+.*?";.*?}' "$OUTPUT_FILE") > reponses_data.txt
(grep -o -P 'question_title";s:\d+:"(.*?)";' "$OUTPUT_FILE") > questions_data.txt
#cat questions_data.txt
#cat reponses_data.txt

# Step 2 fetch  Fetch question title
input_file="questions_data.txt"
counter=1
csv_line=""
# Read the input file line by line and concatenate questions into a CSV line
csv_line=""
while IFS= read -r line; do
   if ((counter < 21 )); then
    # Extract question text between quotes
    # Check if the line contains "question_title"
    question=$(echo "$line" |grep -o -P 'question_title";s:\d+:"(.*?)";'| grep -o -P  ':".*?";' | sed 's/^.\(.*\).$/\1/' | grep -v '"input"' | grep -v '"correct_answer"')
    # Append JSON object to the output
    # Concatenate questions with a comma (CSV format)
    csv_line="${csv_line}${question},"   
    ((counter++))
    fi
done < "$input_file"

# Remove the trailing comma and print the CSV line
echo -e ${csv_line%,}  > output.csv


csv_line=""
# Step 3 Fetch answers 
input_file="reponses_data.txt"
counter=1
csv_line=""
# Read the input file line by line and concatenate questions into a CSV line
csv_line=""
echo $csv_line
while IFS= read -r line; do
   if ((counter % 21 == 0)); then
        csv_line="${csv_line% }"  # Remove the trailing space
        csv_line="${csv_line} \n"
        ((counter++))
    else
    # Extract question text between quotes
      # Check if the line contains "question_title"
 
         reponse=$(echo "$line" |grep -o -P 'user_answer".*?s:[0-9]+:"[a-zA-Z]+.*?";.*?}'| grep -o -P  ':".*?";' | sed 's/^.\(.*\).$/\1/' | grep -v '"input"' | grep -v '"correct_answer"'
 )
        # Append JSON object to the output
        echo -e "${BLUE} ${reponse} ${NC}"
        echo ${csv_line}
        reponse="${reponse// / et }"
        # Concatenate questions with a comma (CSV format)
        csv_line="${csv_line}${reponse},"

    ((counter++))
    fi

done < "$input_file"
echo -e ${csv_line%,}  >> output.csv

rm $OUTPUT_FILE
rm questions_data.txt
rm reponses_data.txt





