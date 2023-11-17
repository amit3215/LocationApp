//
//  LocationViewModelTests.swift
//  PhotoAppTests
//
//  Created by Amit Kumar on 16/9/2023.
//

import XCTest
import PhotoApp
import MapKit

final class LocationViewModelTests: XCTestCase {
    var viewModel: LocationViewModel!
    
    override func setUp() {
        super.setUp()
        let dataPersister = PlistDataPersister()
        viewModel = LocationViewModel(dataPersister: dataPersister)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testAddLocation() {
        let dataPersister = PlistDataPersister()
        let viewModel = LocationViewModel(dataPersister: dataPersister)
        
        let location = Location(location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), name: "Test Location", note: "Test Note")
        
        viewModel.addLocation(location)
        
        // Verify that the location was added to the viewModel's locations array
        XCTAssertEqual(viewModel.locations.count, 1)
        XCTAssertEqual(viewModel.locations.first?.name, "Test Location")
    }
    
    func testWriteData() {
        // Create a LocationViewModel with the mock DataPersister
        let mockDataPersister = MockDataPersister()
        let viewModel = LocationViewModel(dataPersister: mockDataPersister)
        
        // Add a location to trigger the writeData() method
        let location = Location(location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), name: "Test Location", note: "Test Note")
        viewModel.addLocation(location)
        
        // Verify that writeData() was called
        XCTAssertTrue(mockDataPersister.writeDataCalled)
    }
    
    // Test the readPlistFile() method
    func testReadPlistFile() {
        // Create a LocationViewModel with the mock DataPersister
        let mockDataPersister = MockDataPersister()
        let viewModel = LocationViewModel(dataPersister: mockDataPersister)
        
        // Call the readPlistFile() method
        let _ = viewModel.readPlistFile()
        
        // Verify that readPlistFile() was called
        XCTAssertTrue(mockDataPersister.readPlistFileCalled)
    }
    
    // Test the adjustRegionToAnnotations method
    func testAdjustRegionToAnnotations() {
        // Create test locations
        let location1 = Location(location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), name: "Location 1", note: "Note 1")
        let location2 = Location(location: CLLocationCoordinate2D(latitude: 3.0, longitude: 4.0), name: "Location 2", note: "Note 2")
        
        // Add the locations to the viewModel
        viewModel.locations = [location1, location2]
        
        // Calculate the expected region based on the test locations
        let expectedRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 2.0, longitude: 3.0),
            span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 2.0)
        )
        
        // Verify if the calculated region matches the expected region
        let calculatedRegion = viewModel.adjustRegionToAnnotations()
        XCTAssertEqual(calculatedRegion, expectedRegion)
    }
    
    // Test the coordinateFrom(point:region:) method
    func testCoordinateFrom() {
        // Sample region
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
                                        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
        
        // Sample CGPoint (you may need to adjust this based on UI)
        let point = CGPoint(x: 200, y: 300)
        
        let newCoordinate = viewModel.coordinateFrom(point: point, region: region)
        
        XCTAssertEqual(newCoordinate.location.latitude, 52.613839717652645, accuracy: 0.001)
        XCTAssertEqual(newCoordinate.location.longitude, -0.127500000000031, accuracy: 0.001)
    }
    
    // Test the redrawPreviousLocation(region:) method
    func testRedrawPreviousLocation() {
        // Create a LocationViewModel with the mock DataPersister
        let mockDataPersister = MockDataPersister()
        let viewModel = LocationViewModel(dataPersister: mockDataPersister)
        // Create test locations
        let location1 = Location(location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), name: "Location 1", note: "Note 1")
        let location2 = Location(location: CLLocationCoordinate2D(latitude: 3.0, longitude: 4.0), name: "Location 2", note: "Note 2")
        
        // Add the locations to the viewModel
        viewModel.locations = [location1, location2]
        
        viewModel.redrawPreviousLocation()
        
        XCTAssertTrue(mockDataPersister.readPlistFileCalled)
        XCTAssertEqual(viewModel.locations.count, 2)
        XCTAssertEqual(viewModel.locations[0].name, "Location 1")
        XCTAssertEqual(viewModel.locations[1].name, "Location 2")
    }
    
    func testGetLocationObjects() {
        // Mock data for Places array
        let placeArray: [Places] = [
            Places(name: "Place1", lat: 1.0, lng: 2.0),
            Places(name: "Place2", lat: 3.0, lng: 4.0)
        ]
        
        let locations = viewModel.getLocationObjects(placeArray: placeArray)
        
        XCTAssertNotNil(locations)
        XCTAssertEqual(locations?.count, 2)
        
        // Verify that the locations have been correctly created and calculated
        XCTAssertEqual(locations?[0].name, "Place1")
        XCTAssertEqual(locations?[0].location.latitude, 1.0)
        XCTAssertEqual(locations?[0].location.longitude, 2.0)
        
        XCTAssertEqual(locations?[1].name, "Place2")
        XCTAssertEqual(locations?[1].location.latitude, 3.0)
        XCTAssertEqual(locations?[1].location.longitude, 4.0)
    }
    
    func testSortLocations() {
        // Create some Location objects with different distances
        let location1 = Location(location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), name: "Location1", distance: 10.0)
        let location2 = Location(location: CLLocationCoordinate2D(latitude: 3.0, longitude: 4.0), name: "Location2", distance: 5.0)
        let location3 = Location(location: CLLocationCoordinate2D(latitude: 5.0, longitude: 6.0), name: "Location3", distance: 15.0)
        
        // Add them to the locations array in an unsorted order
        viewModel.locations = [location1, location2, location3]
        
        viewModel.sort()
        
        XCTAssertEqual(viewModel.locations.count, 3)
        XCTAssertEqual(viewModel.locations[0].name, "Location2") // Location2 has the smallest distance
        XCTAssertEqual(viewModel.locations[1].name, "Location1")
        XCTAssertEqual(viewModel.locations[2].name, "Location3") // Location3 has the largest distance
    }
}

extension MKCoordinateRegion : Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool { return true }
}
