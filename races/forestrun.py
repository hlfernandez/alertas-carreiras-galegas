import sys
import os
import tempfile
from bs4 import BeautifulSoup
import telegram_sender
from races import Race, SiteRaces

import json
import requests
from utils import text_to_id

class ForestRunEventsParser:

    def __init__(self, html_file_path: str):
        self.html_file_path = html_file_path

    def extract_script_elements(self):
        with open(self.html_file_path, 'r', encoding='utf-8') as file:
            html_content = file.read()

        soup = BeautifulSoup(html_content, 'html.parser')

        script_elements = soup.find_all('script', type='application/ld+json')

        script_contents = [script.get_text() for script in script_elements]

        return script_contents
    
    def get_races(self):
        races = []
        for script_content in self.extract_script_elements():
            json_script_element = json.loads(script_content)

            if not '@graph' in json_script_element.keys():
                date = json_script_element['startDate']
                name = json_script_element['name']
                url = json_script_element['offers']['url']

                races.append(Race(date, name, url))
        
        return races


class ForestRunEventsDownloader:

    baseUrl = 'https://forestrun.es'

    def download(self):
        response = requests.get(self.baseUrl)
        response.raise_for_status()

        with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix=".html") as temp_file:
            temp_file.write(response.text)

            parser = ForestRunEventsParser(temp_file.name)

            return parser.get_races()

class ForestRunRaces(SiteRaces):
    def getDownloader(self):
        return ForestRunEventsDownloader()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('This script requires one argument, which is the path of the CSV to store the races')
        exit(1)

    races = ForestRunRaces(sys.argv[1])
    newRaces = races.updateRaces()
    races.persistRaces()

    telegram_sender.sendTelegram(newRaces, 'forestrun')
