//
//  Server.swift
//  TopApp
//
//  Created by Appspia on 3/9/24.
//

import Foundation

enum Server {
    case dev
    case production
    
    var host: String {
        switch self {
        case .dev:
            return "https://itunes.apple.com"
        case .production:
            return "https://itunes.apple.com"
        }
    }
}
