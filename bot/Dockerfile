# base image
FROM python:3.8-slim-buster
#ARG telegram_bot_token
ARG app_token
ARG app_weather_key

ENV APP_TOKEN=$app_token
ENV APP_WEATHER_KEY=$app_weather_key

#docker build --build-arg token='yyyy' --build-arg api_key='yyyy' -t weather:v2 .

#example env and local var
# ARG telegram_bot_token
# ENV TELEGRAM_bot_token=$telegram_bot_token

RUN env | grep "APP_TOKEN"
RUN env | grep "APP_WEATHER_KEY"

#workdir
WORKDIR /weather_bot

#upgrade pip
RUN pip install --upgrade pip
#install python modules needed by the app
COPY requirements.txt requirements.txt
#RUN python -m venv venv
RUN pip install --no-cache-dir -r requirements.txt
#copy files required for the app run
COPY . /bot

#the port number the container should expose
EXPOSE 80
#run the application
CMD ["python", "weather.py"]
