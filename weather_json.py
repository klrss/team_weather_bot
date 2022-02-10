import requests
import json
import os
import math
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.getenv('APP_WEATHER_KEY')


# for message list

def get_weather(loc):
    try:
        # if city name consists more than one word
        for i in loc:
            if i in [" ", "-"]:
                loc = loc.replace(i, "%20")
        url = 'http://api.openweathermap.org/data/2.5/weather?q={}&units=metric&appid={}'.format(loc, API_KEY)
        data = requests.get(url)
        response = json.loads(data.content.decode('utf8'))
        city = response['name']
        country = response['sys']['country']
        temp = math.ceil(response['main']['temp'])
        feels_like = math.ceil(response['main']['feels_like'])
        wind = response['wind']['speed']
        main = [i['description'] for i in response['weather']]
        day = datetime.today().strftime('%a (%m-%d)')
        msg = '{}. Daily weather forecast in {}, {}: {}°C,' \
              ' feels like {}°C,wind {} m/s, {}.'.format(day, city, country, temp, feels_like, wind, "".join(main))
    except:
        msg = "Please check the spelling of the city. If name is compound try with '-'."
    finally:
        return msg


def geo_weather(lon, lat):
    url = 'http://api.openweathermap.org/data/2.5/weather?lat={}&lon={}&units=metric&appid={}'.format(lat, lon, API_KEY)
    data = requests.get(url)
    response = json.loads(data.content.decode('utf8'))
    city = response['name']
    country = response['sys']['country']
    temp = math.ceil(response['main']['temp'])
    feels_like = math.ceil(response['main']['feels_like'])
    wind = response['wind']['speed']
    main = [i['description'] for i in response['weather']]
    day = datetime.today().strftime('%a (%m-%d)')
    msg = '{}. Daily weather forecast in {}, {}: {}°C,' \
          ' feels like {}°C,wind {} m/s, {}.'.format(day, city, country, temp, feels_like, wind, "".join(main))
    return msg


def get_weather_5(loc):
    msg = []
    msgg=[]
    try:
        # if city name consists more than one word
        for i in loc:
            if i in [" ", "-"]:
                loc = loc.replace(i, "%20")
        url = 'http://api.openweathermap.org/data/2.5/forecast?q={}&units=metric&cnt=5&appid={}'.format(loc, API_KEY)
        data = requests.get(url)
        response = json.loads(data.content.decode('utf8'))
        # json request has {keys:values} pairs, data separation
        city = response['city']['name']
        country = response['city']['country']
        pop = response['city']['population']
        datalist = response['list']
        count = 0  # day count
        day = []  # for day list
        # data as a nested dictionary, getting their
        for i in range(0, len(datalist)):
            temp = [math.ceil(i['main']['temp']) for i in datalist]
            feels_like = [math.ceil(i['main']['feels_like']) for i in datalist]
            main = [i['weather'] for i in response['list']]
            spec = [item['description'] for sublist in main for item in sublist]
            wind = [i['speed'] for i in [i['wind'] for i in response['list']]]
            count += 1
            day.append((datetime.today() + timedelta(days=count)).strftime('%a (%m-%d)'))
            msg.append(day[i] + ": " + str(temp[i]) + "°C, feels like " + str(feels_like[i]) + "°C, " +
                       "wind:" + str(wind[i]) + " m/s, " + str(spec[i]))
        msgg = '{},{}. Population in the city: {}.\n5 Day Weather Forecast: '.format(city, country, pop)
    except:
        msgg = "Please check the spelling of the city. If name is compound try with '-'."
    finally:
        return msgg + "\n" + "\n".join([msg[i] for i in range(0, len(msg))])


def geo_weather_5(lon, lat):
    url = 'http://api.openweathermap.org/data/2.5/forecast?lat={}&lon={}&units=metric&cnt=5&appid={}'.format(lat, lon,
                                                                                                             API_KEY)
    data = requests.get(url)
    response = json.loads(data.content.decode('utf8'))
    # json request has {keys:values} pairs, data separation
    city = response['city']['name']
    country = response['city']['country']
    datalist = response['list']
    pop = response['city']['population']
    count = 0  # day count
    day = []  # for day list
    msg = []  # for message list
    # data as a nested dictionary, getting their
    for i in range(0, len(datalist)):
        temp = [math.ceil(i['main']['temp']) for i in datalist]
        feels_like = [math.ceil(i['main']['feels_like']) for i in datalist]
        wind = [i['speed'] for i in [i['wind'] for i in response['list']]]
        main = [i['weather'] for i in response['list']]
        spec = [item['description'] for sublist in main for item in sublist]
        count += 1
        day.append((datetime.today() + timedelta(days=count)).strftime('%a (%m-%d)'))
        msg.append(day[i] + ": " + str(temp[i]) + "°C, feels like " + str(feels_like[i]) + "°C, "
                   + "wind:" + str(wind[i]) + " m/s, " + str(spec[i]))
    msgg = '{},{}. Population in the city: {}.\n5 Days Weather Forecast: '.format(city, country, pop)

    return msgg + "\n" + "\n".join([msg[i] for i in range(0, len(msg))])


def population(lon, lat):
    url = 'http://api.openweathermap.org/data/2.5/forecast?lat={}&lon={}&units=metric&cnt=5&appid={}'.format(lat, lon,
                                                                                                             API_KEY)
    data = requests.get(url)
    response = json.loads(data.content.decode('utf8'))
    city = response['city']['name']
    country = response['city']['country']
    pop = response['city']['population']
    data = {'city': city, 'country': country, 'population': pop}
    return data


def hist_weather(lon, lat):
    msg = []
    count = 5
    for i in range(0, 5):
        day = (datetime.today() - timedelta(days=count))
        dt = int(day.replace(tzinfo=timezone.utc).timestamp())
        url = 'https://api.openweathermap.org/data/2.5/onecall/timemachine?lat={}&lon={}&exclude=' \
              'hourly&dt={}&units=metric&appid={}'.format(lat, lon, dt, API_KEY)
        data = requests.get(url)
        response = json.loads(data.content.decode('utf8'))
        temp = math.ceil(response['current']['temp'])
        feels_like = math.ceil(response['current']['feels_like'])
        weather = response['current']['weather']
        wind = response['current']['wind_speed']
        spec_list = [i['description'] for i in weather]
        spec = "".join(spec_list)
        count -= 1
        msg.append(day.strftime('%a (%m-%d)') + ": " + str(temp) + "°C, feels like " + str(
            feels_like) + "°C, " + "wind: " + str(wind) + " m/s, " + str(spec) + ".")

    return "\n".join(msg)

