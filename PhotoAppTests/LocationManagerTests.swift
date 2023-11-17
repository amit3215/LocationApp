//
//  LocationManagerTests.swift
//  PhotoApp
//
//  Created by Amit Kumar on 17/9/2023.
//

import XCTest
import CoreLocation
import MapKit
import Combine

final class LocationManagerTests: XCTestCase {
    
    var locationManager: LocationManager!
    var mockDelegate: MockLocationManagerDelegate!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockLocationManagerDelegate()
        locationManager = LocationManager()
    }
    
    override func tearDown() {
        locationManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testUserLocationUpdates() {
        // Create a mock location to be provided by the delegate.
        let mockCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let mockLocation = CLLocation(coordinate: mockCoordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: Date())
        
        // Create an expectation for receiving updates to the userLocation property.
        let expectation = XCTestExpectation(description: "User location should update")
        
        // Set up the location update closure in the mock delegate.
        mockDelegate.locationUpdates = { location in
            // Assert that the received location matches the mock location.
            XCTAssertEqual(location.coordinate.latitude, mockCoordinate.latitude, accuracy: 0.001)
            XCTAssertEqual(location.coordinate.longitude, mockCoordinate.longitude, accuracy: 0.001)
            expectation.fulfill()
        }
        
        // Trigger a mock location update
        let locationManager = CLLocationManager()
        mockDelegate.locationManager(locationManager, didUpdateLocations: [mockLocation])
        
        // Assign a closure to the locationUpdates property
        mockDelegate.locationUpdates = { location in
            // Handle the received location update
            print("Received location update: \(location)")
        }

        // Wait for the expectation to be fulfilled.
        wait(for: [expectation], timeout: 1.0)
    }
    
}

class MockLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var locationUpdates: ((CLLocation) -> Void)?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationUpdates?(location)
        }
    }
}
