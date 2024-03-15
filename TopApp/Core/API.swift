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
        let item: URLRequestItem
        switch self {
        case .free:
            item = URLRequestItem(server.host + "/kr/rss/topfreeapplications/limit=100/json", method: .post)
            item.parameters["test"] = 1
            item.parameters["test2"] = "2"
            item.parameters["test3"] = "한글"
            item.contetType = .wwwFormUrlencoded
        case .paid:
            item = URLRequestItem(server.host + "/kr/rss/toppaidapplications/limit=100/json", method: .get)
        case .grossing:
            item = URLRequestItem(server.host + "/kr/rss/topgrossingapplications/limit=100/json", method: .get)
        }
        
        return dataTaskPublisher(urlRequest: URLRequest(item: item))
    }
}
