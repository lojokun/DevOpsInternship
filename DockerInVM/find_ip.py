import netifaces
import os

for iface in netifaces.interfaces():
  iface_details = netifaces.ifaddresses(iface)
  if netifaces.AF_INET in iface_details:
    print(iface_details[netifaces.AF_INET])

print(iface_details[netifaces.AF_INET][0]['addr'])
os.system(f"export IP={iface_details[netifaces.AF_INET][0]['addr']}")
