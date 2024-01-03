import time
import sys
import os

import telegram_sender
from races import Race

class LocalRaces:
    def __init__(self, newPath: str, publishedPath: str) -> None:
        self.newPath = newPath
        self.publishedPath = publishedPath

        self.newRaces = self.loadRaces(self.newPath)
        self.publishedRaces = self.loadRaces(self.publishedPath)

        for race in self.publishedRaces:
            if race in self.newRaces:
                self.newRaces.remove(race)

    @staticmethod
    def loadRaces(path):
        races = []
        if os.path.isfile(path):
            with open(path, 'r') as src:
                for line in src.readlines():
                    races.append(Race.from_csv_line(line[:-1]))
        
        return races

    def persistRaces(self):
        with open(self.publishedPath, 'w') as dest:
            for race in self.publishedRaces:
                dest.write(str(race))
                dest.write('\n')

        with open(self.newPath, 'w') as dest:
            for race in self.newRaces:
                dest.write(str(race))
                dest.write('\n')
    
    def publish(self, races):
        for race in races:
            self.publishedRaces.append(race)
            self.newRaces.remove(race)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('This script requires one argument, which are the path of the CSV files to retrieve the new races and the published races')
        exit(1)

    races = LocalRaces(sys.argv[1], sys.argv[2])
    
    if len(races.newRaces) == 0:
        print('Nothing to publish from {}'.format(sys.argv[1]))
        exit(0)

    publishedRaces = []
    for race in races.newRaces:
        try:
            telegram_sender.sendTelegramRace(race, 'Manual/Local')
            publishedRaces.append(race)
            time.sleep(5)
        except Exception as e:
            print('*' * 50)
            print('Error sending Telegram message for:', race)
            print(e)
            print('*' * 50)
        
    races.publish(publishedRaces)
    races.persistRaces()