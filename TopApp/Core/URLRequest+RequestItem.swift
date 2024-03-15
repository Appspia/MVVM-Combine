//
//  URLRequest+RequestItem.swift
//  TopApp
//
//  Created by Appspia on 3/14/24.
//

import Foundation

class URLRequestItem {
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    enum ContentType: String {
        case wwwFormUrlencoded = "application/x-www-form-urlencoded"
        case json = "application/json"
    }
    
    let urlString: String
    let httpMethod: HttpMethod
    var headerFields: [String: String] = [:]
    var parameters: [String: Any] = [:]
    var contetType: ContentType = .wwwFormUrlencoded
    
    // MARK: - Options
    var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    var timeoutInterval: TimeInterval = 60
    
    public init(_ url: String, method: HttpMethod) {
        urlString = url
        httpMethod = method
    }
}

extension URLRequest {
    init(item: URLRequestItem) {
        let url: URL?
        var body: Data?
        
        switch item.httpMethod {
        case .get, .delete:
            var components = URLComponents(string: item.urlString)
            components?.queryItems = item.parameters.map { URLQueryItem(name: $0, value: "\($1)") }
            url = components?.url
        case .post, .put:
            url = URL(string: item.urlString)
            item.headerFields["Content-Type"] = item.contetType.rawValue
            if item.contetType == .wwwFormUrlencoded {
                var components = URLComponents()
                components.queryItems = item.parameters.map { URLQueryItem(name: $0, value: "\($1)") }
                body = components.percentEncodedQuery?.data(using: .utf8)
            } else if item.contetType == .json {
                if let jsonData = try? JSONSerialization.data(withJSONObject: item.parameters, options: []) {
                    body = jsonData
                }
            }
        }

        guard let url else { fatalError("invalid URL") }
        self.init(url: url, cachePolicy: item.cachePolicy, timeoutInterval: item.timeoutInterval)
        httpMethod = item.httpMethod.rawValue
        allHTTPHeaderFields = item.headerFields
        httpBody = body
    }
}
