//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Чингиз Джабаев on 13.08.2023.
//

import UIKit

final class MovieQuizPresenter {
    internal let questionsAmount = 10
    private var currentQuestionIndex = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    // метод конвертации, который принимает вопрос и возвращает вью модель для главного экрана
    internal func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
