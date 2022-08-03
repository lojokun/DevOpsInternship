import requests

response = requests.get("http://34.141.67.197:30311?label=m")

print(response.text)