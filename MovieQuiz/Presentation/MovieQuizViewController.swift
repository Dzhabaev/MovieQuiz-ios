import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    // данные на экране
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    struct Actor: Codable {
        let id: String
        let image: String
        let name: String
        let asCharacter: String
    }
    struct Movie: Codable {
        let id: String
        let rank: String
        let title: String
        let fullTitle: String
        let year: String
        let image: String
        let crew: String
        let imDbRating: String
        let imDbRatingCount: String
    }
    struct Top: Decodable {
        let items: [Movie]
    }
    
    // MARK: - IBOutlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Private Properties
    // переменная с индексом текущего вопроса, начальное значение 0 (так как индекс в массиве начинается с 0)
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    // переменная состояния кнопки
    private var isButtonsEnabled = true
    //общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    //контроллер обращаться к фабрики вопросов
    private var questionFactory: QuestionFactoryProtocol?
    //текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    // Здесь объявляем переменную statisticService
    private var statisticService: StatisticService!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
        // Инициализируем переменную statisticService как StatisticServiceImplementation
        statisticService = StatisticServiceImplementation()
        
        // Получение пути к директории документов
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "top250MoviesIMDB.json"
        let fileURL = documentsURL.appendingPathComponent(fileName)
        print(NSHomeDirectory())
        
        // Проверка наличия данных и декодирование JSON
        do {
            let data = try Data(contentsOf: fileURL)
            guard let result = try? JSONDecoder().decode(Top.self, from: data) else {
                print("Ошибка при декодировании JSON")
                return
            }
            // Декодирование успешно, вы можете использовать объект result
        } catch {
            print("Ошибка при загрузке данных: \(error.localizedDescription)")
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private Methods
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        //Создаём константу questionStep и вызываем конструктор QuizStepViewModel;
        let questionStep = QuizStepViewModel(
            //Инициализируем картинку с помощью конструктора UIImage(named: ); если картинки с таким названием не найдётся, подставляем пустую;
            image: UIImage(named: model.image) ?? UIImage(),
            //Просто забираем уже готовый вопрос из мокового вопроса;
            question: model.text,
            //Высчитываем номер вопроса с помощью переменной текущего вопроса currentQuestionIndex и массива со списком вопросов questions. Ииспользуем интерполяцию, то есть подставляем результат в строку, чтобы получилось "X/10";
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            questionFactory?.requestNextQuestion()
        }
    }
    // приватный метод для показа результатов раунда квиза
    // отвечает за отображение алерта с результатами квиза после прохождения всех вопросов
    private func show(quiz result: QuizResultsViewModel) {
        // Обновляем значение gamesCount при каждом вызове метода store
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        // Получаем текущую лучшую игру из сервиса статистики
        let bestGame = statisticService.bestGame
        // Формируем сообщение для алерта
        var message = result.text
        // Получаем информацию о рекорде игры с помощью метода recordText() из структуры GameRecord
        let currentGameRecord = statisticService.bestGame.recordText()
        // Проверяем, что текущая игра лучше лучшей и имеет информацию о рекорде, и добавляем ее к сообщению для алерта
        if bestGame.isBetter(than: statisticService.bestGame), !currentGameRecord.isEmpty {
            message += "\n\n" + currentGameRecord
        }
        // Добавляем информацию о средней точности
        let averageAccuracy = GameRecord.averageAccuracy(totalCorrect: statisticService.totalCorrectAnswers, totalQuestions: statisticService.totalQuestionsPlayed)
        // Добавляем информацию о количестве сыгранных квизов
        message += "\nКоличество сыгранных квизов: \(statisticService.gamesCount)"
        // Добавляем информацию о лучшем результате
        message += "\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        // Добавляем информацию о средней точности
        message += "\nСредняя точность: \(String(format: "%.2f", averageAccuracy))%"
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
                // Перезапуск квиза, когда пользователь нажимает кнопку в алерте
                self?.startNewGame()
            }
        let alertPresenter = AlertPresenter(presentingViewController: self)
        alertPresenter.presentAlert(with: alertModel)
    }
    // Метод для перезапуска игры
    private func startNewGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        //использeуем UIFeedbackGenerator для вибраций при правильных и неправильных ответах
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(isCorrect ? .success : .error)
        // блокируем кнопки
        isButtonsEnabled = false
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else {return} // слабая ссылка на self
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            // разблокируем кнопки
            self.isButtonsEnabled = true
        }
    }
    
    // MARK: - IBActions
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled, let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
    }
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled, let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: false == currentQuestion.correctAnswer)
    }
}
