//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Чингиз Джабаев on 18.07.2023.
//
import Foundation
protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
    func loadData()
    func resetData()
}
