import telegram
import os

def escapeMarkdown(text):
    toScape = ['_', '(', ')', '+', '-', '=', '|', '{', '}', '.', '!']
    for rep in toScape:
        text = text.replace(rep, '\\' + rep)
    
    return text

def sendTelegramRace(race, source):
    try:
        BOT_ID_TOKEN = os.environ['BOT_ID_TOKEN']
        CHAT_ID = os.environ['CHAT_ID']
    except KeyError:
        raise Exception('Error, BOT_ID_TOKEN and CHAT_ID must be provided')

    url = 'https://api.telegram.org/bot{}/sendMessage'.format(BOT_ID_TOKEN)

    message = '*{name}*\n - Data: {date}\n - Vía: {source} \n - Máis información: {url}'.format(name = race.name, date = race.date, source = source, url = race.url)
    message = escapeMarkdown(message)

    print('[telegram_sender.py] sendTelegram: new race')
    print(message)

    myBot = telegram.Bot(BOT_ID_TOKEN)
    myBot.send_message('@' + CHAT_ID, message, parse_mode = 'MarkdownV2')

def sendTelegram(races, source):
    for race in races:
        try:
            sendTelegramRace(race, source)
        except Exception as e:
            print('*' * 50)
            print('Error sending Telegram message for:', race)
            print(e)
            print('*' * 50)
