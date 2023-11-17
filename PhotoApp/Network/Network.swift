//
//  Network.swift
//  PhotoApp
//
//  Created by Amit Kumar on 17/9/2023.
//

import Foundation
import Combine

// Protocol for defining the network service contract
protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: APIEndpoint, completion: @escaping (Result<T, Error>) -> Void)
}

// Enum to represent API endpoints
enum APIEndpoint {
    case location
    var url: URL {
        switch self {
        case .location:
            return URL(string: "https://www.anyPI.limited/tht/locations.json")!
        }
    }
}

// Implement the network service class that conforms to the protocol
class NetworkService: NetworkServiceProtocol {
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: APIEndpoint, completion: @escaping (Result<T, Error>) -> Void) {
        print(endpoint)
        print(T.Type.self)
        URLSession.shared.dataTask(with: endpoint.url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Invalid Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(type, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
