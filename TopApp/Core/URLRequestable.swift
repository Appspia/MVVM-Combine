//
//  URLRequestable.swift
//  TopApp
//
//  Created by Appspia on 3/9/24.
//

import Foundation
import Combine

enum ResponseError: Error, Equatable {
    case badURL
    case networkError(code: Int)
    case invalidJSON(String)
    case sessionExpired
}

protocol URLRequestable {}

extension URLRequestable {
    func dataTaskPublisher<T: Codable>(urlRequest: URLRequest) -> AnyPublisher<T, ResponseError> {
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                guard let urlResponse = result.response as? HTTPURLResponse, urlResponse.statusCode == 401 else {
                    return result
                }
                throw ResponseError.sessionExpired
            }
            .tryCatch { error -> AnyPublisher<(data: Data, response: URLResponse), any Error> in
                try sessionRestorePublisher(urlRequest: urlRequest)
            }
            .tryMap { (data: Data, response: URLResponse) in
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                switch statusCode {
                case 200..<300:
                    return data
                case 401:
                    throw ResponseError.sessionExpired
                default:
                    throw ResponseError.networkError(code: statusCode)
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                ResponseError.invalidJSON(String(describing: error))
            }
            .eraseToAnyPublisher()
    }
    
    private func sessionRestorePublisher(urlRequest: URLRequest) throws -> AnyPublisher<(data: Data, response: URLResponse), any Error> {
        API<String>.grossing.request
            .tryMap { _ in
                throw ResponseError.sessionExpired
            }
            .tryCatch { error -> URLSession.DataTaskPublisher in
                // urlRequest.allHTTPHeaderFields 해더 변경
                return URLSession.shared.dataTaskPublisher(for: urlRequest)
            }
            .eraseToAnyPublisher()
    }
}
