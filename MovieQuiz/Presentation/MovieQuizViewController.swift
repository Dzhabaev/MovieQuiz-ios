import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter?
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = StatisticServiceImplementation()
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader())
        presenter = MovieQuizPresenter(viewController: self, questionFactory: questionFactory, statisticService: StatisticServiceImplementation())
        alertPresenter = AlertPresenter(presentingViewController: self)
        showLoadingIndicator()
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - UI Update Methods
    // Метод вывода на экран вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    // Метод для показа результатов раунда квиза
    func show(quiz result: QuizResultsViewModel) {
        if let presenter = presenter {
            let message = presenter.makeResultsMessage()
            let alertModel = AlertModel(
                title: result.title,
                message: message,
                buttonText: result.buttonText,
                completion: { [weak self] in
                    guard self != nil else { return }
                    presenter.restartGame()
                },
                accessibilityIdentifier: "Game results")
            alertPresenter?.presentAlert(with: alertModel)
        }
    }
    // Метод, который меняет цвет рамки
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        if let presenter = self.presenter {
            let alert = UIAlertController(
                title: "Ошибка",
                message: message,
                preferredStyle: .alert)
            let action = UIAlertAction(title: "Попробовать ещё раз",
                                       style: .default) { [weak self] _ in
                guard self != nil else { return }
                presenter.restartGame()
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    @IBAction private func playAgainButtonClicked(_ sender: UIButton) {
        presenter?.playAgainButtonClicked()
    }
}
