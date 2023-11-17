//
//  MockNetworkService.swift
//  PhotoAppTests
//
//  Created by Amit Kumar on 17/9/2023.
//

import XCTest

class MockNetworkService: NetworkServiceProtocol {
        var shouldSucceed = true
        var testData: Data?
        
        func fetch<T: Decodable>(_ type: T.Type, from endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {
            if shouldSucceed {
                if let data = testData {
                    do {
                        let decodedData = try JSONDecoder().decode(type, from: data)
                        completion(.success(decodedData))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NSError(domain: "Invalid Data", code: 0, userInfo: nil)))
                }
            } else {
                completion(.failure(NSError(domain: "Mock Error", code: 1, userInfo: nil)))
            }
        }
}
    
