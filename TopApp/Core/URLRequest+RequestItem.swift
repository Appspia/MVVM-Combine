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
        case mulipartFormData = "multipart/form-data; boundary=BOUNDARY"
    }
    
    let urlString: String
    let httpMethod: HttpMethod
    var headerFields: [String: String] = [:]
    var parameters: [String: Any] = [:]
    var contetType: ContentType = .wwwFormUrlencoded
    
    // MARK: - Multipart
    struct MultipartItem {
        enum ContentType {
            case data
            case png
            case jpg
            case custom(String)
            
            var toString: String {
                switch self {
                case .data:
                    return "application/octet-stream"
                case .png:
                    return "image/png"
                case .jpg:
                    return "image/jpeg"
                case let .custom(value):
                    return value
                }
            }
        }

        var contentType: ContentType
        var name: String
        var data: Data
        var fileName: String
        
        init(contentType: ContentType, name: String, data: Data, fileName: String?) {
            self.contentType = contentType
            self.name = name
            self.data = data
            self.fileName = fileName ?? NSUUID().uuidString
        }
    }
    var multipartItems: [MultipartItem] = []
    
    // MARK: - Options
    var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    var timeoutInterval: TimeInterval = 60
    
    public init(_ url: String, method: HttpMethod) {
        urlString = url
        httpMethod = method
    }
    
    func addMultipartItem(contentType: MultipartItem.ContentType, name: String, data: Data, fileName: String?) {
        let multipartItem = MultipartItem(contentType: contentType, name: name, data: data, fileName: fileName)
        multipartItems.append(multipartItem)
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
            } else if item.contetType == .mulipartFormData {
                var formBody = Data()
                for (key, value) in item.parameters {
                    formBody.append(string: "--BOUNDARY\r\n")
                    formBody.append(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    formBody.append(string: "\(value)\r\n")
                }
                
                for multipartItem in item.multipartItems {
                    formBody.append(string: "--BOUNDARY\r\n")
                    formBody.append(string: "Content-Disposition: form-data; name=\"\(multipartItem.name)\"; filename=\"\(multipartItem.fileName)\"\r\n")
                    formBody.append(string: "Content-Type: \(multipartItem.contentType.toString)\r\n\r\n")
                    formBody.append(multipartItem.data)
                    formBody.append(string: "\r\n")
                }
                formBody.append(string: "--BOUNDARY--\r\n")
                body = formBody
            }
        }

        guard let url else { fatalError("invalid URL") }
        self.init(url: url, cachePolicy: item.cachePolicy, timeoutInterval: item.timeoutInterval)
        httpMethod = item.httpMethod.rawValue
        allHTTPHeaderFields = item.headerFields
        httpBody = body
    }
}

extension Data {
    mutating func append(string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
