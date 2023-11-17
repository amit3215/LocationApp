//
//  NetworkServiceTests.swift
//  PhotoAppTests
//
//  Created by Amit Kumar on 17/9/2023.
//

import XCTest

final class NetworkServiceTests: XCTestCase {
    func testFetchSuccess() {
         // Given
         let expectation = self.expectation(description: "Fetch Success")
         let networkService = MockNetworkService()
         networkService.shouldSucceed = true
         networkService.testData = """
             {
                 "locations": [
                     {
                                 "name" : "Location1",
                                 "lat" : 32.323,
                                 "lng" : 323.3223
                     }
                ],
                  "updated" : "2016-12-0T"
             }
         """.data(using: .utf8)
         
         // When
         networkService.fetch(LocationModel.self, from: .location) { result in
             // Then
             switch result {
             case .success(let decodedData):
                 XCTAssertEqual(decodedData.updated, "2016-12-0T")
                 XCTAssertEqual(decodedData.locations?.first?.name, "Location1")
                 XCTAssertEqual(decodedData.locations?.first?.lat, 32.323)
                 XCTAssertEqual(decodedData.locations?.first?.lng, 323.3223)
                 expectation.fulfill()
             case .failure(let error):
                 XCTFail("Expected success, but got failure: \(error)")
             }
         }
         
         waitForExpectations(timeout: 5.0, handler: nil)
     }
     
     func testFetchFailure() {
         // Given
         let expectation = self.expectation(description: "Fetch Failure")
         let networkService = MockNetworkService()
         networkService.shouldSucceed = false
         
         // When
         networkService.fetch(LocationModel.self, from: .location) { result in
             // Then
             switch result {
             case .success:
                 XCTFail("Expected failure, but got success")
             case .failure(let error):
                 XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (Mock Error error 1.)")
                 expectation.fulfill()
             }
         }
         
         waitForExpectations(timeout: 5.0, handler: nil)
     }
 }
