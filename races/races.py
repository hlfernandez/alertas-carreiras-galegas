import os

# TODO: add type annotations and use PEP-8 code style

class Race:
    def __init__(self, date, name, url):
        self.url = url
        self.name = name
        self.date = date

    def __str__(self):
        return '{};{};{}'.format(self.date, self.name, self.url)

    def __eq__(self, other):
        return self.url == other.url and self.name == other.name and self.date == other.date

    @staticmethod
    def fromCsvLine(csvLine):
        split = csvLine.split(';')
        return Race(split[0], split[1], split[2])

class SiteRaces:
    def __init__(self, path: str, eventPages = 1) -> None:
        self.path = path

        if os.path.isfile(self.path):
            self.races = self.loadRaces()
        else:
            self.races = []
        
        self.eventPages = eventPages

    def loadRaces(self):
        races = []
        with open(self.path, 'r') as src:
            for line in src.readlines():
                races.append(Race.fromCsvLine(line[:-1]))
        
        return races

    def persistRaces(self):
        with open(self.path, 'w') as dest:
            for race in self.races:
                dest.write(str(race))
                dest.write('\n')

    def updateRaces(self):
        webRaces = self.getDownloader().download()
        newRaces = []

        for race in webRaces:
            if not race in self.races:
                self.races.append(race)
                newRaces.append(race)

        return newRaces
