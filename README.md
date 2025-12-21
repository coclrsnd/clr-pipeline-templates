# clr-pipeline-templates

## SSH Key Setup for EC2 Deployment

### Required Secrets

Set these secrets in your GitHub repository:

- `AWS_EC2_KEY_B64`: Base64-encoded private SSH key
- `AWS_EC2_HOST`: EC2 instance public IP or DNS name
- `AWS_EC2_USER`: SSH username (optional, defaults to trying `ec2-user`, `ubuntu`, `centos`, `admin`)
- `AWS_REGION`: AWS region
- `AWS_ACCOUNT_ID`: AWS account ID

### SSH Key Setup Instructions

1. **Generate or locate your SSH key pair:**
   ```bash
   # Generate new key pair (RSA)
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/ec2-deploy-key

   # Or use existing key
   ls ~/.ssh/
   ```

2. **Ensure you have the private key:**
   - The private key should start with `-----BEGIN OPENSSH PRIVATE KEY-----` or `-----BEGIN RSA PRIVATE KEY-----`
   - **Do NOT use the public key (.pub file)**

3. **Convert to base64 and set as secret:**
   ```bash
   # For OpenSSH format key
   cat ~/.ssh/ec2-deploy-key | base64 -w 0

   # For PEM format key (common with AWS)
   cat ~/.ssh/ec2-deploy-key.pem | base64 -w 0
   ```

4. **Install public key on EC2 instance:**
   ```bash
   # Copy public key to EC2 instance
   ssh-copy-id -i ~/.ssh/ec2-deploy-key.pub ec2-user@your-ec2-instance

   # Or manually append to authorized_keys
   cat ~/.ssh/ec2-deploy-key.pub | ssh ec2-user@your-ec2-instance "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
   ```

5. **Set repository secrets:**
   - Go to GitHub → Repository → Settings → Secrets and variables → Actions
   - Add `AWS_EC2_KEY_B64` with the base64-encoded private key
   - Add other required secrets

### Troubleshooting

The workflow now includes enhanced debugging that will:
- Test SSH connectivity
- Try multiple common usernames
- Convert PEM keys to OpenSSH format
- Provide verbose SSH output for diagnosis

### Common Issues

1. **"Permission denied"**: Check that the private key matches the public key on EC2
2. **"Host key verification failed"**: The workflow automatically adds host keys
3. **"Connection refused"**: Ensure EC2 security group allows SSH (port 22) from GitHub Actions IPs
4. **"Invalid key"**: Ensure you're using the private key, not public key, and it's base64 encoded correctly