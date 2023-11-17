//
//  LocationViewModel.swift
//  PhotoApp
//
//  Created by Amit Kumar on 17/9/2023.
//

import SwiftUI
import CoreLocation
import MapKit

class LocationViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var locationManager = LocationManager()
    let networkService: NetworkServiceProtocol = NetworkService()
    var dataPersister: DataPersister?
    
    init(dataPersister: DataPersister? = nil) {
        self.dataPersister = dataPersister
    }
}

// MARK: Plist read write methods
extension LocationViewModel {
    func writeData() {
        dataPersister?.writeData(locations: locations)
    }
    
    func readPlistFile() -> LocationModel? {
        return dataPersister?.readPlistFile()
    }
    
    func redrawPreviousLocation() {
        if let data = dataPersister?.readPlistFile() {
            guard let locationArrayData = data.locations else {
                return
            }
            
            let arrayToWrite = locationArrayData.map { place in
                var location = Location(location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
                if let lat = place.lat, let lng = place.lng, let name = place.name, let notes = place.notes {
                    location = Location(location: CLLocationCoordinate2D(latitude: lat, longitude: lng), name: name, note: notes)
                    location.calculateDistance(currentUserLocation: locationManager.userLocation)
                }
                return location
            }
            
            self.locations = arrayToWrite
            self.writeData()
        }
    }
}

// MARK: API calling methods
extension LocationViewModel {
    func getLocationData(completion: @escaping (Bool) -> Void) async {
        networkService.fetch(LocationModel.self, from: .location) { result in
            switch result {
            case .success(let fetchedPosts):
                guard let placeArray = fetchedPosts.locations else {
                    return
                }
                if let locationArrayFromPlaces = self.getLocationObjects(placeArray: placeArray) {
                    DispatchQueue.main.async {
                        self.locations = locationArrayFromPlaces
                        self.redrawPreviousLocation()
                        self.writeData()
                        completion(true)
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
    }
    
    
}

// MARK: Helper methods
extension LocationViewModel {
    // Add methods to interact with the location array
    func addLocation(_ location: Location) {
        locations.append(location)
        writeData()
    }
    
    func getLocationObjects(placeArray: [Places]) -> [Location]? {
        let dataToWrite = placeArray.map { place in
            if let lat = place.lat, let lng = place.lng, let name = place.name {
                var location = Location(location: CLLocationCoordinate2D(latitude: lat, longitude: lng), name: name)
                location.calculateDistance(currentUserLocation: locationManager.userLocation)
                return location
            }
            // Provide default coordinate center of map
            return Location(location: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275))
        }
        return dataToWrite
    }
    
    // Helper function to create an MKPointAnnotation
    func adjustRegionToAnnotations() -> MKCoordinateRegion? {
        if locations.isEmpty {
            return nil
        }
        
        var minLat = locations.first?.location.latitude
        var maxLat = locations.first?.location.latitude
        var minLong = locations.first?.location.longitude
        var maxLong = locations.first?.location.longitude
        
        for annotation in locations {
            let lat = annotation.location.latitude
            let long = annotation.location.longitude
            
            if lat < minLat! {
                minLat = lat
            }
            if lat > maxLat! {
                maxLat = lat
            }
            if long < minLong! {
                minLong = long
            }
            if long > maxLong! {
                maxLong = long
            }
        }
        
        let centerLat = (minLat! + maxLat!) / 2
        let centerLong = (minLong! + maxLong!) / 2
        let spanLat = maxLat! - minLat! + 0.4
        let spanLong = maxLong! - minLong! + 0.4
        
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong - 1)
        let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong + 10.0)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func coordinateFrom(point: CGPoint, region: MKCoordinateRegion) -> Location  {
        let mkMapView = MKMapView(frame: CGRect(x: 0, y: 50, width: 400, height: UIScreen.main.bounds.size.height - 100))
        mkMapView.region = region
        let newCoordinate = mkMapView.convert(point, toCoordinateFrom: mkMapView)
        var newLocation = Location(location: newCoordinate, isUserAdded: true)
        newLocation.calculateDistance(currentUserLocation: locationManager.userLocation)
        self.addLocation(newLocation)
        return newLocation
    }
    
    func sort() {
        self.locations = self.locations.sorted { $0.distance < $1.distance }
    }
}
