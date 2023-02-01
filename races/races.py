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
