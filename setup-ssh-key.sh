#!/bin/bash

# SSH Key Setup Script for EC2 Deployment
# This script helps you prepare SSH keys for GitHub Actions deployment

set -e

echo "=== SSH Key Setup for EC2 Deployment ==="
echo

# Check if key already exists
if [ -f ~/.ssh/ec2-deploy-key ]; then
    echo "Existing SSH key found at ~/.ssh/ec2-deploy-key"
    read -p "Do you want to use the existing key? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Generating new SSH key..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/ec2-deploy-key -N ""
    fi
else
    echo "Generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/ec2-deploy-key -N ""
fi

echo
echo "=== Public Key (add this to your EC2 instance) ==="
echo "Run this command on your EC2 instance:"
echo "echo '$(cat ~/.ssh/ec2-deploy-key.pub)' >> ~/.ssh/authorized_keys"
echo
echo "Or use ssh-copy-id:"
echo "ssh-copy-id -i ~/.ssh/ec2-deploy-key.pub ec2-user@YOUR_EC2_IP"
echo

echo "=== Private Key (base64 encoded for GitHub secret) ==="
echo "Copy this base64 string to your GitHub repository secrets as 'AWS_EC2_KEY_B64':"
echo
cat ~/.ssh/ec2-deploy-key | base64 -w 0
echo
echo

echo "=== Next Steps ==="
echo "1. Add the public key to your EC2 instance's ~/.ssh/authorized_keys"
echo "2. Copy the base64 private key to GitHub: Settings → Secrets → AWS_EC2_KEY_B64"
echo "3. Ensure your EC2 security group allows SSH (port 22) from 0.0.0.0/0 or GitHub Actions IPs"
echo "4. Set other required secrets: AWS_REGION, AWS_ACCOUNT_ID, AWS_EC2_HOST"
echo
echo "For detailed instructions, see README.md"
