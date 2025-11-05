//
//  Search.swift
//  MovieDB-CSS214
//
//  Created by Sapuan Talaspay on 11/4/25.
//

import Foundation

struct SearchResponse: Codable {
    let page: Int?
    let results: [Result]?
    let totalPages: Int?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
