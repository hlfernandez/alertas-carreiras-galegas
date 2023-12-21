import sys
import os

import telegram_sender
from races import Race, SiteRaces

from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

class MagmaEventsDownloader:

    baseUrl = 'https://magmasports.es/es?page={page}'

    def __init__(self, numPages: int):
        self.numPages = numPages

    @staticmethod
    def getUrl(line: str) -> str:
        return line[line.find('href="')+6:line.find('" style')]

    def download(self):
        webRaces = []
        for i in range(1, self.numPages +1 ):
            webRaces.extend(self.processMagmaEvents(MagmaEventsDownloader.baseUrl.format(page = str(i))))
        
        return webRaces

    @staticmethod
    def newRace(urlLine: str, nameLine: str, dateLine: str) -> Race:
        return Race(dateLine[:-1].strip(), nameLine.strip(), urlLine.strip())

    @staticmethod
    def processEventName(name: str) -> str:
        return name.replace('&amp;', '&')

    def processMagmaEvents(self, url):
        races = []
        req = Request(url)
        try:
            with urlopen(req) as f:
                eventName = None
                eventUrl = None
                # TODO: try enums for encoding the status (https://docs.python.org/3/library/enum.html)
                status = None
                for line in f:
                    line = line.decode('utf-8')

                    if status == 'FIND_DATE':
                        lineCount = lineCount + 1
                        if lineCount == 12:
                            races.append(self.newRace(eventUrl, eventName, line))
                            status = None
                            eventName = None
                            eventUrl = None
                    elif status == 'RACE_NAME':
                        eventName = self.processEventName(line[:-1])
                        status = 'FIND_DATE'
                        lineCount = 1
                    elif status == 'NEW_EVENT':
                        if line.find('/evento/') != -1:
                            eventUrl = self.getUrl(line)
                            status = 'RACE_NAME'
                        if line.find('/eventos/') != -1:
                            races.extend(self.processMagmaEvents(self.getUrl(line)))
                            status = None
                    elif line.find('<div class="event-title mb-15">') != -1:
                            status = 'NEW_EVENT'

            return races
        except HTTPError as e:
            print('The server couldn\'t fulfill the request.')
            print('Error code: ', e.code)
        except URLError as e:
            print('We failed to reach a server.')
            print('Reason: ', e.reason)

class MagmaSportsRaces(SiteRaces):
    def getDownloader(self):
        return MagmaEventsDownloader(self.eventPages)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('This script requires one argument, which is the path of the CSV to store the races')
        exit(1)

    races = MagmaSportsRaces(sys.argv[1], 2)
    newRaces = races.updateRaces()
    races.persistRaces()

    telegram_sender.sendTelegram(newRaces, 'MagmaSports')
    