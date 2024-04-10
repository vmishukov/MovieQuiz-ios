import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter : MovieQuizPresenter!
    private var alertPresener: AlertPresenterProtocol?
      
    // MARK: - Lifecycle
    
    // константа с кнопкой для системного алерта
    override func viewDidLoad() {
        alertPresener = AlertPresenter(delegate: self)
        
        showLoadingIndicator()
        
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.cornerRadius = 20 // радиус скругления картинки
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        presenter = MovieQuizPresenter(viewController: self)
        super.viewDidLoad()
    }
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
       
        presenter.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
  
        presenter.yesButtonClicked()
    }
    // MARK: - Private functions
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let viewModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion:  {[weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
                // Перенесли вызов `questionFactory?.requestNextQuestion()` в `restartGame()`
            })
        showAlert(viewModel: viewModel)
        // создайте и покажите алерт
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAlert(viewModel: AlertModel) {
        alertPresener?.show(model: viewModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        self.noButton.isEnabled = false
        self.yesButton.isEnabled = false
    }
    
    func nextQuestionClearence() {
        self.imageView.layer.borderColor = UIColor.clear.cgColor
        self.noButton.isEnabled = true
        self.yesButton.isEnabled = true
    }
    
}
