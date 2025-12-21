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

echo "=== Private Key for GitHub Secrets ==="
echo
echo "OPTION 1: Raw key (recommended - copy entire content to AWS_EC2_KEY secret):"
echo "----------------------------------------"
cat ~/.ssh/ec2-deploy-key
echo
echo "----------------------------------------"
echo
echo "OPTION 2: Base64 encoded (copy to AWS_EC2_KEY_B64 secret):"
echo "----------------------------------------"
cat ~/.ssh/ec2-deploy-key | base64 -w 0
echo
echo "----------------------------------------"
echo

echo "=== Next Steps ==="
echo "1. Add the public key to your EC2 instance's ~/.ssh/authorized_keys"
echo "2. Set GitHub secret (choose one option):"
echo "   - Go to: GitHub → Repository → Settings → Secrets and variables → Actions"
echo "   - OPTION 1: Create secret 'AWS_EC2_KEY' with the raw key content above"
echo "   - OPTION 2: Create secret 'AWS_EC2_KEY_B64' with the base64 content above"
echo "3. Set other required secrets: AWS_REGION, AWS_ACCOUNT_ID, AWS_EC2_HOST"
echo "4. Ensure your EC2 security group allows SSH (port 22) from GitHub Actions IPs"
echo
echo "For detailed instructions, see README.md"
