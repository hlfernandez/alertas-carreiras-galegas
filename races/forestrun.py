import sys
import tempfile
import json
from typing import List
import requests
from bs4 import BeautifulSoup
import telegram_sender
from races import Race, SiteRaces


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

    def get_races(self) -> List[Race]:
        downloaded_races: List[Race] = []
        for script_content in self.extract_script_elements():
            json_script_element = json.loads(script_content)

            if not '@graph' in json_script_element.keys():
                date = json_script_element['startDate']
                name = json_script_element['name']
                url = json_script_element['offers']['url']

                downloaded_races.append(Race(date, name, url))

        return downloaded_races


class HtmlDownloader:

    def __init__(self) -> None:
        self.html_file = ''

    def download_file(self, base_url: str) -> None:

        response = requests.get(base_url, timeout=240)
        response.raise_for_status()

        with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix=".html") as temp_file:
            temp_file.write(response.text)

            self.html_file = temp_file.name


class ForestRunEventsDownloader(HtmlDownloader):

    baseUrl = 'https://forestrun.es'

    def download(self)  -> List[Race]:
        self.download_file(self.baseUrl)

        parser = ForestRunEventsParser(self.html_file)

        return parser.get_races()

class ForestRunRaces(SiteRaces):
    def getDownloader(self):
        return ForestRunEventsDownloader()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('This script requires one argument, which is the path of the CSV to store the races')
        exit(1)

    races = ForestRunRaces(sys.argv[1])
    newRaces: List[Race] = races.updateRaces()
    races.persistRaces()

    telegram_sender.sendTelegram(newRaces, 'forestrun')
