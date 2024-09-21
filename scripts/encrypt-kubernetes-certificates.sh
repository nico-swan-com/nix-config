#!/bin/sh

# Create or clear the output YAML file
OUTPUT_FILE="$1/certificates.yaml"
echo "" > "$OUTPUT_FILE"

# Iterate over each file in the current directory
for FILE in $(sudo ls -1 /var/lib/kubernetes/secrets/*.pem); do
    if [[ -f "$FILE" ]]; then
        FILENAME=$(basename "$FILE")
	    echo "$FILENAME"
        echo "$FILENAME: |" >> "$OUTPUT_FILE"
        sudo bash -c "cat $FILE" | sed 's/^/    /' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

echo "YAML file created successfully."

sops --encrypt --in-place --config $1/.sops.yaml  $OUTPUT_FILE
git add .
echo "Certificates encrypted successfully."