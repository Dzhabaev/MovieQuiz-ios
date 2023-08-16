//
//  KPPopularMovies.swift
//  MovieQuiz
//
//  Created by Чингиз Джабаев on 16.08.2023.
//

import Foundation
// MARK: - Kinopoisk
struct Kinopoisk: Codable {
    let docs: [KPMovie]
}

// MARK: - KPMovie
struct KPMovie: Codable {
    let kprating: Rating
    let id: Int
    let title: String
    let poster: Poster
    
    enum CodingKeys: String, CodingKey {
        case kprating = "rating"
        case id
        case title = "name"
        case poster
    }
}

extension KPMovie: Movie {
    var rating: String {
        "\(kprating.kp)"
    }
    
    var imageURL: URL {
        URL(string: poster.previewUrl)!
    }
    
    var resizedImageURL: URL {
        imageURL
    }
}

// MARK: - Poster
struct Poster: Codable {
    let url, previewUrl: String
}

// MARK: - Rating
struct Rating: Codable {
    let kp, imdb: Double
} 
