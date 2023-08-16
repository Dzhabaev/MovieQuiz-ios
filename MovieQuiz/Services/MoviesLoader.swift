//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Чингиз Джабаев on 31.07.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<[Movie], Error>) -> Void)
}

enum MovieLoaderApiType {
    case kp, imdb
}

class MoviesLoader: MoviesLoading {
    
    private var apiType: MovieLoaderApiType = .imdb
    private lazy var requestFactory: MovieLoaderRequestFactory = MovieLoaderRequestFactoryImpl()
    private lazy var responceHendler: MoviesLoaderResponceHandler = MoviesLoaderResponceHandlerImpl()
    
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    // MARK: - URL
    func loadMovies(handler: @escaping (Result<[Movie], Error>) -> Void) {
        networkClient.fetch(request: requestFactory.constructRequest(api: apiType)) { [unowned self] result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try  responceHendler.handleResponce(data: data, api: apiType)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
