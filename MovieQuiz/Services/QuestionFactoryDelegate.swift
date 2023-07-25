import Foundation
//протокол, используемый в фабрике как делегат
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
