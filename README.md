# clr-pipeline-templates

## SSH Key Setup for EC2 Deployment

### Required Secrets

**Where to set them**: GitHub → Your Repository → Settings → Secrets and variables → Actions → New repository secret

Create these repository secrets (set either `AWS_EC2_KEY` **OR** `AWS_EC2_KEY_B64`):

| Secret Name | Required | Description | Example Value |
|-------------|----------|-------------|---------------|
| `AWS_EC2_KEY` **OR** `AWS_EC2_KEY_B64` | Yes* | Private SSH key (raw content or base64-encoded) | `-----BEGIN RSA PRIVATE KEY-----...` |
| `AWS_EC2_HOST` | Yes | EC2 instance public IP or DNS name | `54.123.45.67` or `my-ec2.example.com` |
| `AWS_EC2_USER` | No | SSH username (auto-detected if not set) | `ec2-user`, `ubuntu`, `centos`, or `admin` |
| `AWS_REGION` | Yes | AWS region | `us-east-1`, `eu-west-1`, etc. |
| `AWS_ACCOUNT_ID` | Yes | AWS account ID | `123456789012` |

*Either `AWS_EC2_KEY` or `AWS_EC2_KEY_B64` must be provided.

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

3. **Verify and set as GitHub secret:**

   **Option A: Store raw key directly (recommended)**
   ```bash
   # First, verify your key
   ./verify-ssh-key.sh ~/.ssh/ec2-deploy-key

   # Then copy the entire private key content to GitHub secret AWS_EC2_KEY
   cat ~/.ssh/ec2-deploy-key
   ```

   **Option B: Base64-encoded (legacy)**
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
   - Go to your GitHub repository
   - Click **Settings** tab
   - Scroll down and click **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - **For raw PEM**: Name: `AWS_EC2_KEY`, Value: paste your entire private key content
   - **For base64**: Name: `AWS_EC2_KEY_B64`, Value: paste the base64-encoded key
   - Add other required secrets: `AWS_EC2_HOST`, `AWS_REGION`, `AWS_ACCOUNT_ID`

### Troubleshooting

The workflow now includes enhanced debugging that will:
- Test SSH connectivity
- Try multiple common usernames
- Convert PEM keys to OpenSSH format
- Provide verbose SSH output for diagnosis

### Common Issues

1. **"Permission denied (publickey,gssapi-keyex,gssapi-with-mic)"**: SSH key authentication failed
   - **Cause**: SSH key secret not set, or public key not installed on EC2
   - **Solution**: Run `./setup-ssh-key.sh` and follow the instructions carefully

2. **"Host key verification failed"**: The workflow automatically adds host keys
3. **"Connection refused"**: Ensure EC2 security group allows SSH (port 22) from GitHub Actions IPs
4. **"Invalid key"**: Ensure you're using the private key, not public key. The workflow supports both raw and base64-encoded formats.

### If SSH Test Fails

When you see "SSH authentication failed for all users", check:

1. **GitHub Secret**: Is `AWS_EC2_KEY` secret set with the exact content from `./setup-ssh-key.sh`?
2. **EC2 Public Key**: Is the public key installed on your EC2 instance?
3. **Key Format**: Make sure you're copying the ENTIRE private key (including BEGIN/END lines)
4. **Secret Name**: Use `AWS_EC2_KEY` (not `AWS_EC2_KEY_B64`)