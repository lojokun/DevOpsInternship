echo "Updating system..."
sudo apt update
echo "Update complete!"

echo "Downloading neccesities for terraform..."
sudo apt-get install wget unzip -y
echo "Download complete!"

echo "Downloading and installing terraform..."
sudo wget https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
sudo unzip terraform_0.14.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/
echo "Download complete!"

echo "Downloading ansible..."
sudo apt install ansible -y
echo "Download complete!"

echo "Downloading and installing AzureClient..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
echo "Download complete!"
