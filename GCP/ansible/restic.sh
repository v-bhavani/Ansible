#!/bin/bash

# Set Google Cloud project ID
export GOOGLE_PROJECT_ID=mymigration-322809

# Set path to Google Cloud service account credentials
export GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gs-secret-restic.json

# List of repositories and their corresponding passwords
declare -A repo_passwords
repo_passwords["backup"]="Symphony"
repo_passwords["backup1"]="Symphony1"
repo_passwords["backup2"]="Symphony2"
repo_passwords["backup3"]="Symphony3"

# Create an HTML file with a styled table for all repositories
cat <<EOF >output_all.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Command Output - All Repositories</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial;
            font-size: 14px;
            line-height: 20px;
            font-weight: 400;
            color: #3b3b3b;
            -webkit-font-smoothing: antialiased;
            font-smoothing: antialiased;
            background: #ecf0f1; /* Background color for the body */
            margin: 20px;
        }
        h1 {
            color: #3498db; /* Heading color */
            text-align: center;
        }
        table {
            border-collapse: collapse;
            width: 80%;
            margin: 20px auto;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 8px; /* Add border-radius for rounded corners */
            overflow: hidden;
        }
        th, td {
            border: 1px solid #ecf0f1; /* Border color */
            padding: 15px;
            text-align: left;
            transition: background 0.3s; /* Add transition for smooth hover effect */
        }
        th {
            background-color: #3498db; /* Header background color */
            color: #fff;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9; /* Alternate row color */
        }
        tr:hover {
            background-color: #e0e0e0; /* Hover color */
        }
    </style>
</head>
<body>
    <h1>Restic Backup Details</h1>
    <table>
        <tr>
            <th>Repository</th>
            <th>Number of Snapshots</th>
            <th>Last Backup Time</th>
            <th>Repo Size</th>
        </tr>
EOF

# Loop through repositories and append data to the HTML file
for repo in "${!repo_passwords[@]}"; do
    # Get the password for the current repository
    repo_password="${repo_passwords[$repo]}"

    # Run the commands with the Restic password and capture the output for each repository
    output_length=$(RESTIC_PASSWORD=$repo_password restic -r gs:restic1:/$repo snapshots --json | jq 'length')
    output_time=$(RESTIC_PASSWORD=$repo_password restic -r gs:restic1:/$repo snapshots --json | jq -r '.[-1].time')
    output_size=$(gsutil du -s gs://restic1/$repo/** | awk '{printf "%.7f GB\n", $1/1024^3}')

    # Append data to the HTML file
    cat <<EOF >>output_all.html
        <tr> 
            <td>$repo</td>
            <td>$output_length</td>
            <td>$output_time</td>
            <td>$output_size</td>
        </tr>
EOF
done

# Close the HTML file
cat <<EOF >>output_all.html
    </table>
</body>
</html>
EOF

echo "HTML file created: output_all.html"
