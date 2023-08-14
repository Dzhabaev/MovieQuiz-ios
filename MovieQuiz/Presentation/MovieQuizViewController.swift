import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
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
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    // Метод для показа результатов раунда квиза
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    // Метод, который меняет цвет рамки
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать ещё раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        alert.addAction(action)
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
