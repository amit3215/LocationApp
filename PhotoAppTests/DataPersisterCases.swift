//
//  DataPersisterCases.swift
//  PhotoAppTests
//
//  Created by Amit Kumar on 17/9/2023.
//

import XCTest
import PhotoApp
import MapKit

final class DataPersisterCases: XCTestCase {

    // Mock LocationProtocol for testing
        struct MockLocation: LocationProtocol {
            var name: String
            var note: String
            var location: CLLocationCoordinate2D
        }

        // Test the writeData method
        func testWriteData() {
            let dataPersister = PlistDataPersister()
            let location = MockLocation(name: "Test Location", note: "Test Note", location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0))
            dataPersister.writeData(locations: [location])

            let plistFileName = "data.plist"
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let plistURL = documentsDirectory?.appendingPathComponent(plistFileName)
            XCTAssertTrue(FileManager.default.fileExists(atPath: plistURL!.path))
        }

        // Test the readPlistFile method
        func testReadPlistFile() {
            let dataPersister = PlistDataPersister()

            // Write test data to the plist
            let location = MockLocation(name: "Test Location", note: "Test Note", location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0))
            dataPersister.writeData(locations: [location])

            // Read data from the plist
            let locationModel = dataPersister.readPlistFile()

            XCTAssertNotNil(locationModel)
            XCTAssertEqual(locationModel?.locations?.count, 1)
            XCTAssertEqual(locationModel?.locations?[0].name, "Test Location")
        }

}
