//
//  MockDataPersister.swift
//  PhotoAppTests
//
//  Created by Amit Kumar on 17/9/2023.
//

import Foundation
// Create a mock DataPersister
class MockDataPersister: DataPersister {
    var writeDataCalled = false
    var readPlistFileCalled = false
    
    func writeData(locations: [LocationProtocol]) {
        writeDataCalled = true
    }

    func readPlistFile() -> LocationModel? {
        readPlistFileCalled = true
        return nil
    }
}
