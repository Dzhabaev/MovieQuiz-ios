import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    // данные на экране
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
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
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    //текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // заново показываем первый вопрос
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
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
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                show(quiz: viewModel)
            }
        }
    }
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText,
                                   style: .default) { [weak self] _ in // слабая ссылка на self
            guard let self = self else {return} // разворачиваем слабую ссылку
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
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
        guard isButtonsEnabled else {
            return
        }
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else {
            return
        }
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}



