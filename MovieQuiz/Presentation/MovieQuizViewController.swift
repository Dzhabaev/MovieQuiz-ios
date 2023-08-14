import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    private var statisticService: StatisticService!
    private var alertPresenter: AlertPresenter!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticServiceImplementation()
        loadDataFromJSON()
        alertPresenter = AlertPresenter(presentingViewController: self)
        showLoadingIndicator()
        activityIndicator.hidesWhenStopped = true
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Private Methods
    // Вспомогательный метод для загрузки данных из JSON
    private func loadDataFromJSON() {
        guard let fileURL = getJSONFileURL() else {
            print("Не удалось получить путь к JSON файлу.")
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            guard (try? JSONDecoder().decode(Top.self, from: data)) != nil else {
                print("Ошибка при декодировании JSON")
                return
            }
            // Декодирование успешно, вы можете использовать объект result
        } catch {
            print("Ошибка при загрузке данных: \(error.localizedDescription)")
        }
    }
    // Вспомогательный метод для получения пути к JSON файлу
    private func getJSONFileURL() -> URL? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "top250MoviesIMDB.json"
        let fileURL = documentsURL.appendingPathComponent(fileName)
        print(NSHomeDirectory())
        return fileURL
    }
    
    // MARK: - UI Update Methods
    // Метод вывода на экран вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    // Метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            // идём в состояние "Результат квиза"
            let text = "Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
        }
    }
    // Метод для показа результатов раунда квиза
    func show(quiz result: QuizResultsViewModel) {
        statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        let bestGame = statisticService.bestGame
        var message = result.text
        let currentGameRecord = statisticService.bestGame.recordText
        if bestGame.isBetter(than: statisticService.bestGame), !currentGameRecord.isEmpty {
            message += "\n\n" + currentGameRecord
        }
        let averageAccuracy = GameRecord.averageAccuracy(totalCorrect: statisticService.totalCorrectAnswers, totalQuestions: statisticService.totalQuestionsPlayed)
        message += "\nКоличество сыгранных квизов: \(statisticService.gamesCount)"
        message += "\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        message += "\nСредняя точность: \(String(format: "%.2f", averageAccuracy))%"
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
                self?.presenter.restartGame()
            }
        let alertPresenter = AlertPresenter(presentingViewController: self)
        alertPresenter.presentAlert(with: alertModel)
    }
    // Метод для перезапуска игры
    private func startNewGame() {
        presenter.restartGame()
    }
    // Метод, который обнуляет текущий прогресс квиза.
    private func resetQuiz() {
        presenter.restartGame()
    }
    // Метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        //использeуем UIFeedbackGenerator для вибраций при правильных и неправильных ответах
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(isCorrect ? .success : .error)
        // блокируем кнопки
        presenter.isButtonsEnabled = false
        if isCorrect {
            presenter.correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.presenter.showNextQuestionOrResults()
            // разблокируем кнопки
            self.presenter.isButtonsEnabled = true
        }
    }
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            self?.presenter.restartGame()
        }
        alertPresenter.presentAlert(with: model)
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
