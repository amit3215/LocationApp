//
//  LocationModel.swift
//  PhotoApp
//
//  Created by Amit Kumar on 17/9/2023.
//

import Foundation
import MapKit

struct Location: Identifiable {
    var id = UUID()
    var location : CLLocationCoordinate2D
    var name: String = "New Place"
    var distance: Double = 0
    var note: String = ""
    var isUserAdded: Bool = false
}

extension Location {
    mutating func calculateDistance(currentUserLocation: CLLocationCoordinate2D?) {
        guard let currentUserLocation else { return }
        let location1 = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let location2 = CLLocation(latitude: currentUserLocation.latitude, longitude: currentUserLocation.longitude)
        self.distance = location1.distance(from: location2)
    }
}

struct LocationModel: Decodable {
    var locations: [Places]?
    var updated: String?
}

struct Places: Decodable {
    var name: String?
    var lat: Double?
    var lng: Double?
    var notes: String?
}
