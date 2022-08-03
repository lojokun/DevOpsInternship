import subprocess

print("Extracting the IP addresses...")
webapp_IP_encoded = subprocess.check_output(
    "az vm list-ip-addresses --resource-group rg-devopsint-mihai_losonczi --name webapp | grep ipAddress", shell=True)
mongodb_IP_encoded = subprocess.check_output(
    "az vm list-ip-addresses --resource-group rg-devopsint-mihai_losonczi --name mongodb | grep ipAddress", shell=True)
webapp_IP = webapp_IP_encoded.decode().split(":")[1][2:-3]
mongodb_IP = mongodb_IP_encoded.decode().split(":")[1][2:-3]
print("Extraction done!")

print("Creating inventory...")
with open("./provision/inventory/inventory", "w") as f:
    f.write("[webapps]\n")
    f.write("webapp1\n")
    f.write("\n")
    f.write("[dbs]\n")
    f.write("db1\n")
    f.write("\n")
    f.write("[all:vars]\n")
    f.write("ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n")
    f.write("ansible_python_interpreter=/usr/bin/python3\n")
    f.write("\n")
    f.write("[webapps:vars]\n")
    f.write(f"ansible_ssh_host={webapp_IP}\n")
    f.write("ansible_ssh_user=webapp\n")
    f.write("ansible_ssh_private_key_file=/home/vagrant/.ssh/webapp_key.pem\n")
    f.write("\n")
    f.write("[dbs:vars]\n")
    f.write(f"ansible_ssh_host={mongodb_IP}\n")
    f.write("ansible_ssh_user=mongodb\n")
    f.write("ansible_ssh_private_key_file=/home/vagrant/.ssh/mongodb_key.pem\n")
print("Inventory created!")
