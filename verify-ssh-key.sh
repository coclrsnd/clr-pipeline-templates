#!/bin/bash

# SSH Key Verification Script
# Run this locally to verify your SSH key before setting GitHub secrets

echo "=== SSH Key Verification ==="
echo

# Check if key file exists
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-private-key-file>"
    echo "Example: $0 ~/.ssh/ec2-deploy-key"
    exit 1
fi

KEY_FILE="$1"

if [ ! -f "$KEY_FILE" ]; then
    echo "ERROR: Key file '$KEY_FILE' not found"
    exit 1
fi

echo "Checking key file: $KEY_FILE"
echo

# Check if it's a private key
if grep -q "BEGIN.*PRIVATE KEY" "$KEY_FILE"; then
    echo "✓ File contains private key header"
else
    echo "✗ File does not appear to be a private key"
    echo "Make sure you're using the private key file (not .pub file)"
    exit 1
fi

# Check key format
if ssh-keygen -l -f "$KEY_FILE" >/dev/null 2>&1; then
    echo "✓ SSH key is valid and properly formatted"
    ssh-keygen -l -f "$KEY_FILE"
else
    echo "⚠ SSH key may need format conversion"
    if grep -q "BEGIN RSA PRIVATE KEY" "$KEY_FILE"; then
        echo "This appears to be a PEM format key - the workflow will auto-convert it"
    else
        echo "Unknown key format - please check your key file"
    fi
fi

echo
echo "=== Content for AWS_EC2_KEY secret ==="
echo "Copy everything between the lines below to your GitHub AWS_EC2_KEY secret:"
echo "----------------------------------------"
cat "$KEY_FILE"
echo
echo "----------------------------------------"
echo
echo "Set this as a GitHub repository secret named 'AWS_EC2_KEY'"
echo "GitHub → Repository → Settings → Secrets and variables → Actions"
