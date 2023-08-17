//
//  MovieLoaderRequestFactory.swift
//  MovieQuiz
//
//  Created by Чингиз Джабаев on 16.08.2023.
//

import Foundation

 protocol MovieLoaderRequestFactory {
    func constructRequest(api: MovieLoaderApiType) -> URLRequest
}

class MovieLoaderRequestFactoryImpl: MovieLoaderRequestFactory {
    func constructRequest(api: MovieLoaderApiType) -> URLRequest {
        switch api {
        case .kp:
            var components = URLComponents(string: "https://api.kinopoisk.dev/v1.3/movie")!
            components.queryItems = [
                URLQueryItem(name: "selectFields",
                             value: ["id", "name", "rating", "poster"].joined(separator: " ")
                            ),
                URLQueryItem(name: "limit", value: "250"),
                URLQueryItem(name: "typeNumber", value: "1"),
                URLQueryItem(name: "top250", value: "!null")
            ]
            var request = URLRequest(url: components.url!)
            request.timeoutInterval = 2 // Времени ожидания ответа от сервера 2 секунды
            request.addValue("JX95J99-GQH44DA-KJ6T9Q5-STB3F0N", forHTTPHeaderField: "X-API-KEY")
            return request
        case .imdb:
            guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
                preconditionFailure("Unable to construct mostPopularMoviesUrl")
            }
            return URLRequest(url: url)
        }
    }
}
