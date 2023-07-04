import sys
import os

import telegram_sender
from races import Race, SiteRaces

import json
import requests
from utils import text_to_id

class CarreirasGalegasEventsDownloader:

    baseUrl = 'https://api.web.carreirasgalegas.com/competitions-by-month'

    def download(self):
        webRaces = self.processCarreirasGalegasEvents(self.baseUrl)
        
        return webRaces

    @staticmethod
    def race_url(json_race:str) -> str:
        return '{}/{}/{}'.format(
            'https://www.carreirasgalegas.com/events',
            text_to_id(json_race['name']), 
            json_race['id']
        )
    
    @staticmethod
    def newRace(json_race: str) -> Race:
        return Race(json_race['date'], json_race['name'], CarreirasGalegasEventsDownloader.race_url(json_race))

    def processCarreirasGalegasEvents(self, url):
        request = requests.get(url)
        request.raise_for_status()

        races = []

        for month in json.loads(request.content):
            for json_race in month['competitions']:
                races.append(self.newRace(json_race))

        return races

class CarreirasGalegasRaces(SiteRaces):
    def getDownloader(self):
        return CarreirasGalegasEventsDownloader()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('This script requires one argument, which is the path of the CSV to store the races')
        exit(1)

    races = CarreirasGalegasRaces(sys.argv[1])
    newRaces = races.updateRaces()
    races.persistRaces()

    telegram_sender.sendTelegram(newRaces, 'Carreiras Galegas')
    