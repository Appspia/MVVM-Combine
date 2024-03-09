//
//  API.swift
//  TopApp
//
//  Created by Appspia on 3/9/24.
//

import Foundation
import Combine

enum API<T: Codable>: URLRequestable {
    case free
    case paid
    case grossing
}

extension API {
    var request: AnyPublisher<T, ResponseError> {
        let requestData: ASRequestData
        switch self {
        case .free:
            requestData = ASRequestData(urlString: server.rawValue + "/kr/rss/topfreeapplications/limit=100/json", httpMethod: .get)
        case .paid:
            requestData = ASRequestData(urlString: server.rawValue + "/kr/rss/toppaidapplications/limit=100/json", httpMethod: .get)
        case .grossing:
            requestData = ASRequestData(urlString: server.rawValue + "/kr/rss/topgrossingapplications/limit=100/json", httpMethod: .get)
        }
        return dataTaskPublisher(urlRequest: URLRequest(requestData: requestData))
    }
}
