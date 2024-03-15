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
//            .tryMap { result in
//                guard let urlResponse = result.response as? HTTPURLResponse, urlResponse.statusCode == 401 else {
//                    return result
//                }
//                throw ResponseError.sessionExpired
//            }
//            .tryCatch { error -> AnyPublisher<(data: Data, response: URLResponse), any Error> in
//                try sessionRestorePublisher(urlRequest: urlRequest)
//            }
            .handleEvents(receiveOutput: { (data: Data, response: URLResponse) in
                let urlString = urlRequest.url?.absoluteString ?? ""
                let httpURLResponse = response as? HTTPURLResponse
                print("""
                --------------- HTTP REQUEST ----------------
                URL: \(urlString)
                HEADER: \(prettyString(urlRequest.allHTTPHeaderFields))
                BODY: \(prettyString(urlRequest.httpBody))
                --------------- HTTP RESPONSE ---------------
                URL: \(urlString)
                HEADER: \(prettyString(httpURLResponse?.allHeaderFields))
                STATUS: \(String(httpURLResponse?.statusCode ?? 0))
                DATA: \(prettyString(data))
                ---------------------------------------------
                """)
            })
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
    
//    private func sessionRestorePublisher(urlRequest: URLRequest) throws -> AnyPublisher<(data: Data, response: URLResponse), any Error> {
//        API<String>.grossing.request
//            .map { result in
//                return result
////                throw ResponseError.sessionExpired
//            }
//            .flatMap { _ in
//                URLSession.shared.dataTaskPublisher(for: urlRequest).mapError { $0 as Error }
//            }
////            .switchToLatest()
////            .tryCatch { error -> URLSession.DataTaskPublisher in
////                // urlRequest.allHTTPHeaderFields 해더 변경
////                return URLSession.shared.dataTaskPublisher(for: urlRequest)
////            }
////            .eraseToAnyPublisher()
//    }
}

private extension URLRequestable {
    func prettyString(_ jsonDic: Any?) -> String {
        var prettyString: String = ""
        if let jsonDic, let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted) {
            prettyString = String(data: data, encoding: .utf8) ?? ""
        }
        return prettyString
    }
    
    func prettyString(_ data: Data?) -> String {
        var prettyString: String = ""
        if let data {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
                   prettyString = String(data: jsonData, encoding: .utf8) ?? ""
               }
            } else {
                prettyString = String(data: data, encoding: .utf8) ?? ""
            }
        }
        return prettyString
    }
}
