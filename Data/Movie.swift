//
//  Movie.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 18/6/2024.
//

import Foundation
struct MovieResponse: Decodable {
    let Search: [Movie]
}

struct Movie: Identifiable, Decodable {
    
    let title: String
    let year: String
    let imdbId: String
    let poster: URL?
    
    var id: String {
        imdbId
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbId = "imdbID"
        case poster = "Poster"
    }
}
