//
//  TopAppsItem.swift
//  TopApp
//
//  Created by Appspia on 3/16/24.
//

import Foundation

enum TopAppsItem {
    struct TopApps: Codable {
        let feed: Feed
    }

    struct Feed: Codable {
        var entry: [Entry]
    }

    struct Entry: Codable {
        let imName: Rights?
        let imImage: [IMImage]?
        let summary: Rights?
        let imPrice: IMPrice?
        let imContentType: IMContentType?
        let rights: Rights?
        let title: Rights?
        var id: Entryid?
        let imArtist: IMArtist?
        let category: Category?
        let imReleaseDate: IMReleaseDate?
        
        private enum CodingKeys: String, CodingKey {
            case imName = "im:name"
            case imImage = "im:image"
            case summary
            case imPrice = "im:price"
            case imContentType = "im:contentType"
            case rights
            case title
            case id
            case imArtist = "im:artist"
            case category
            case imReleaseDate = "im:releaseDate"
        }
    }
    
    struct Rights: Codable {
        let label: String?
    }

    struct Category: Codable {
        let attributes: CategoryAttributes?
    }

    struct CategoryAttributes: Codable {
        let imid: String?
        let term: String?
        let scheme: String?
        let label: String?
    }

    struct Entryid: Codable {
        var label: String?
        let attributes: IDAttributes?
    }

    struct IDAttributes: Codable {
        let imid: String?
        
        private enum CodingKeys: String, CodingKey {
            case imid = "im:id"
        }
    }

    struct IMArtist: Codable {
        let label: String?
        let attributes: IMArtistAttributes?
    }

    struct IMArtistAttributes: Codable {
        let href: String?
    }

    struct IMContentType: Codable {
        let attributes: IMContentTypeAttributes?
    }

    struct IMContentTypeAttributes: Codable {
        let term: String?
        let label: String?
    }

    struct IMImage: Codable {
        let label: String?
        let attributes: IMImageAttributes?
    }

    struct IMImageAttributes: Codable {
        let height: String?
    }

    struct IMPrice: Codable {
        let label: String?
        let attributes: IMPriceAttributes?
    }

    struct IMPriceAttributes: Codable {
        let amount: String?
        let currency: String?
    }

    struct IMReleaseDate: Codable {
        let label: String?
        let attributes: Rights?
    }

    struct FluffyAttributes: Codable {
        let rel: String?
        let type: String?
        let href: String?
    }
}
