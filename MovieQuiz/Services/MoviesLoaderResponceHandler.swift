//
//  MoviesLoaderResponceHandler.swift
//  MovieQuiz
//
//  Created by Чингиз Джабаев on 16.08.2023.
//

import Foundation

protocol MoviesLoaderResponceHandler {
    func handleResponce(data: Data, api: MovieLoaderApiType) throws -> [Movie]
}

class MoviesLoaderResponceHandlerImpl: MoviesLoaderResponceHandler {
    func handleResponce(data: Data, api: MovieLoaderApiType) throws -> [Movie] {
        switch api {
        case .kp:
            return try JSONDecoder().decode(Kinopoisk.self, from: data).docs
        case .imdb:
            return try JSONDecoder().decode(MostPopularMovies.self, from: data).items
        }
    }
}
