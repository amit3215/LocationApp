//
//  DataPersister.swift
//  PhotoApp
//
//  Created by Amit Kumar on 17/9/2023.
//

import Foundation
import MapKit

protocol LocationProtocol {
    var name: String { get }
    var note: String { get }
    var location: CLLocationCoordinate2D { get }
}

// Conform Location to the LocationProtocol
extension Location: LocationProtocol {}

protocol DataPersister {
    func writeData(locations: [LocationProtocol])
    func readPlistFile() -> LocationModel?
}

struct PlistDataPersister: DataPersister {
    private let plistFileName = "data.plist"
    
    func writeData(locations: [LocationProtocol]) {
        let dataToWrite = locations.map { location in
            return [
                "name": location.name,
                "notes": location.note,
                "lat": location.location.latitude,
                "lng": location.location.longitude
            ] as [String : Any]
        }
        
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let plistURL = documentsDirectory.appendingPathComponent(plistFileName)
            do {
                let plistDataS: [String: Any] = ["locations": dataToWrite]
                let plistData = try PropertyListSerialization.data(fromPropertyList: plistDataS, format: .xml, options: 0)
                try plistData.write(to: plistURL)
            } catch {
                print("Error writing Plist file: \(error)")
            }
        }
    }
    
    func readPlistFile() -> LocationModel? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let plistURL = documentsDirectory.appendingPathComponent(plistFileName)
            
            if FileManager.default.fileExists(atPath: plistURL.path) {
                if let plistData = NSDictionary(contentsOf: plistURL) as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: plistData, options: [])
                        let decoder = JSONDecoder()
                        let locations = try decoder.decode(LocationModel?.self, from: jsonData)
                        return locations
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                print("Plist file not found.")
            }
        } else {
            print("Documents directory not found.")
        }
        return nil
    }
}
