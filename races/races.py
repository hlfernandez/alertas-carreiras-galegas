import os
from abc import ABCMeta, abstractmethod

class Race:
    def __init__(self, date, name, url):
        self.url = url
        self.name = name
        self.date = date

    def __str__(self):
        return f'{self.date};{self.name};{self.url}'

    def __eq__(self, other):
        return self.url == other.url and self.name == other.name and self.date == other.date

    @staticmethod
    def from_csv_line(csv_line: str):
        split = csv_line.split(';')
        return Race(split[0], split[1], split[2])

class SiteRaces(metaclass=ABCMeta):
    def __init__(self, path: str, event_pages = 1) -> None:
        self.path = path

        if os.path.isfile(self.path):
            self.races = self.load_races()
        else:
            self.races = []

        self.event_pages = event_pages

    @abstractmethod
    def get_downloader(self):
        pass

    def load_races(self):
        races = []
        with open(self.path, 'r', encoding='utf-8') as src:
            for line in src.readlines():
                races.append(Race.from_csv_line(line[:-1]))

        return races

    def persist_races(self):
        with open(self.path, 'w', encoding='utf-8') as dest:
            for race in self.races:
                dest.write(str(race))
                dest.write('\n')

    def update_races(self):
        downloaded_races = self.get_downloader().download()
        new_races = []

        for race in downloaded_races:
            if not race in self.races:
                self.races.append(race)
                new_races.append(race)

        return new_races
