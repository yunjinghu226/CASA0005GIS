import googlemaps
import csv
import time

gmaps = googlemaps.Client(key='AIzaSyASW8btzoW1bgSF0ONXmxHhM-_hNR3oh48')

with open('huntlocations.csv', mode='r') as locationsFile:
    with open('geocodedHuntLocations.csv', mode='w') as geocodedLocationsFile:
        locationsReader = csv.reader(locationsFile)
        locationsWriter = csv.writer(geocodedLocationsFile)
        locationsWriter.writerow(['location', 'lat', 'lng', 'points'])

        # skip headers
        next(locationsReader)

        for location in locationsReader:
            locationAddress = location[0]
            points = location[1]

            geocodedResult = gmaps.geocode(locationAddress)
            geocodedResult = geocodedResult[0]

            if (geocodedResult):
                locationsWriter.writerow([
                    locationAddress,
                    geocodedResult.get('geometry').get('location').get('lat'),
                    geocodedResult.get('geometry').get('location').get('lng'),
                    points
                ])

            time.sleep(2)
