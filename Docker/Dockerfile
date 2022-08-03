# syntax=docker/dockerfile:experimental
FROM python:3
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN ./mongo_init.sh
#CMD [ "cd", "app" ; "python", "-m", "flask", "app/run" ]
CMD sudo systemctl start mongod ; cd app ; python -m  flask run --host "172.17.0.2" --port 3000
#CMD ./mongo_init.sh
EXPOSE 3000