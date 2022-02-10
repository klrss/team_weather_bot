import logging
from telegram.ext import Updater, CommandHandler
from telegram.ext import MessageHandler, Filters
from weather_json import *
import os
from sqlalchemy import create_engine, exists
from sqlalchemy.orm import sessionmaker

from dotenv import load_dotenv
from models import UserCoord

load_dotenv()
# logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO
)
logger = logging.getLogger(__name__)

# connection to postgres database
engine = create_engine(os.getenv('APP_DATABASE_URL'))
conn = engine.connect()
Session = sessionmaker(engine)
s = Session()


def start_handler(update, context):
    chat_id = update.effective_chat.id
    context.bot.send_message(chat_id=chat_id, text='Hello!\nType /help for instructions.')
    # update.message.reply_text("Type /help for instructions.")


def help_handler(update, context):
    update.message.reply_text(
        "/weather city. City is a city, where you want to know daily weather forecast.\n"
        "/weather5 city. The weather forecast for 5 days."
        "\nFor example, \n\t\t\t /weather Berlin\n\t\t\t /weather5 Kyiv. \n"
        "/loc. Command to send your location.\n"
        "/geo, to know daily weather forecast by location.\n"
        "/geo5 , to know 5 days weather forecast by location.\n"
        "/hist , to know 5 days history of weather forecast. It's needs to send location at first.")


def weather_handler(update, context):
    # check arguments as location name
    if context.args:
        loc = "".join(context.args)
        result = get_weather(loc)
        context.bot.send_message(chat_id=update.effective_chat.id, text="".join(result))
    else:
        context.bot.send_message(chat_id=update.effective_chat.id,
                                 text="/weather city\nWrite location name as a argument.")


def weather_handler_5(update, context):
    # check arguments as location name
    if context.args:
        loc = "".join(context.args)
        result_5 = get_weather_5(loc)
        context.bot.send_message(chat_id=update.effective_chat.id, text="".join(result_5))


# location
def loc_send_handler(update, context):
    context.bot.send_message(chat_id=update.effective_chat.id, text="Send your location.")


def commit_to_db(update, context):  # write to database
    lat = str(update.message.location.latitude)
    lon = str(update.message.location.longitude)
    name = update.message.from_user.first_name
    u_id = update.message.from_user.id
    data = population(lon, lat)
    city = data['city']
    usercoord = UserCoord(u_id=u_id, name=name, lat=lat, lon=lon, city=data['city'],
                          country=data['country'], pop=data['population'])
    # check if already exists the same row in the database
    qr = s.query(exists().where(UserCoord.u_id == u_id, UserCoord.lat == lat,
                                UserCoord.lon == lon, UserCoord.city == city)).scalar()
    try:
        if qr is False:
            s.add(usercoord)
            s.commit()
    finally:
        s.close()

    context.bot.send_message(chat_id=update.effective_chat.id,
                             text='I know coordinates.\n/geo , the current weather \n/geo5  5 days forecast.'
                                  '\n/hist  the weather, what was five days ago.')


# daily weather forecast
def geo_handler(update, context):
    chat_id = update.effective_chat.id
    u_id = update.message.from_user.id
    try:
        loc = s.query(UserCoord.lat, UserCoord.lon).filter_by(u_id=u_id).limit(1).all()
        result = geo_weather(loc[0][1], loc[0][0])
    finally:
        s.close()

    context.bot.send_message(chat_id=chat_id, text='{}'.format(result))


# five day weather forecast
def geo_handler_5(update, context):
    chat_id = update.effective_chat.id
    u_id = update.message.from_user.id
    try:
        loc = s.query(UserCoord.lat, UserCoord.lon).filter_by(u_id=u_id).limit(1).all()
        result5 = geo_weather_5(loc[0][1], loc[0][0])
    finally:
        s.close()
    context.bot.send_message(chat_id=chat_id, text='{}'.format(result5))


def hist_handler(update, context):
    chat_id = update.effective_chat.id
    u_id = update.message.from_user.id
    try:
        loc = s.query(UserCoord.lat, UserCoord.lon).filter_by(u_id=u_id).limit(1).all()
        result = hist_weather(loc[0][1], loc[0][0])
    finally:
        s.close()

    context.bot.send_message(chat_id=chat_id, text='By your coordinates the weather was: {}'.format(result))


def main():
    APP_TOKEN = os.getenv('APP_TOKEN')
    updater = Updater(APP_TOKEN, use_context=True)
    updater.dispatcher.add_handler(CommandHandler("start", start_handler))
    updater.dispatcher.add_handler(CommandHandler("help", help_handler))
    updater.dispatcher.add_handler(CommandHandler("loc", loc_send_handler))
    updater.dispatcher.add_handler(CommandHandler("geo", geo_handler))
    updater.dispatcher.add_handler(CommandHandler("geo5", geo_handler_5))
    updater.dispatcher.add_handler(CommandHandler("weather", weather_handler))
    updater.dispatcher.add_handler(CommandHandler("weather5", weather_handler_5))
    updater.dispatcher.add_handler(MessageHandler(Filters.location, commit_to_db))
    updater.dispatcher.add_handler(CommandHandler("hist", hist_handler))
    updater.start_polling()
    updater.idle()


if __name__ == '__main__':
    main()
