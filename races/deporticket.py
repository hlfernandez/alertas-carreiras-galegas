import sys
import telegram_sender
from races import Race, SiteRaces

from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

class DeporticketDownloader:

    baseUrl = 'https://www.deporticket.com/?p={page}'

    def __init__(self, numPages: int = 1):
        self.numPages = numPages

    def download(self):
        webRaces = []
        for i in range(0, self.numPages ):
            webRaces.extend(self.processEvents(DeporticketDownloader.baseUrl.format(page = str(i))))

        return webRaces
    
    @staticmethod
    def includeLocation(location: str):
        return (location.find('Ourense') != -1 or 
                location.find('Galicia') != -1 or 
                location.find('Pontevedra') != -1 or 
                location.find('A Coruña') != -1 or 
                location.find('Lugo') != -1)

    @staticmethod
    def includeName(location: str):
        location = location.lower()
        return (location.find('bike') == -1 and 
                location.find('btt') == -1 and 
                location.find('ciclo') == -1 and 
                location.find('nado') == -1)

    def processEvents(self, url):
        races = []
        req = Request(url)
        try:
            with urlopen(req) as f:
                eventName = None
                eventUrl = None
                eventDate = None
                # TODO: try enums for encoding the status (https://docs.python.org/3/library/enum.html)
                status = None
                for line in f:
                    line = line.decode('utf-8')
                    if status == 'NEXT_IS_LOCATION':
                        eventLocation = line.rstrip()
                        if (DeporticketDownloader.includeLocation(eventLocation) and 
                            DeporticketDownloader.includeName(eventName)):
                            races.append(Race(eventDate, eventName, eventUrl))
                        status = None
                        eventName = None
                        eventUrl = None
                        eventDate = None
                    if status == 'NEW_EVENT':
                        if line.find('<div class="media-body g-mt-10">') != -1:
                            status = 'NEXT_IS_LOCATION'
                    elif line.find('a class="g-color-gray-dark-v2" href') != -1:
                        status = 'NEW_EVENT'
                        title = '" title="'
                        href = 'href="'
                        eventUrl = line[line.index(href)+len(href):line.index(title)]
                        eventName = line[line.index(title)+len(title):line.index('">')]
                        if eventUrl.startswith('/web-evento/'):
                            eventUrl = 'https://www.deporticket.com/{}'.format(eventUrl)
                    elif line.find('<time datetime="') != -1:
                        dateMarker = '<time datetime="'
                        eventDate = line[line.index(dateMarker)+len(dateMarker):line.find('">')]

            return races
        except HTTPError as e:
            print('The server couldn\'t fulfill the request.')
            print('Error code: ', e.code)
        except URLError as e:
            print('We failed to reach a server.')
            print('Reason: ', e.reason)
    
class DeporticketRaces(SiteRaces):
    def getDownloader(self):
        return DeporticketDownloader(self.eventPages)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('This script requires one argument, which is the path of the CSV to store the races')
        exit(1)

    races = DeporticketRaces(sys.argv[1], 4)
    newRaces = races.updateRaces()
    races.persistRaces()

    telegram_sender.sendTelegram(newRaces, 'Deporticket')
    