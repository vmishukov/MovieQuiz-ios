import UIKit

final class MovieQuizViewController: UIViewController {
    
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
    
    // MARK: - QuestionFactoryDelegate
    // Удалите функцию `didRecieveNextQuestion(question: QuizQuestion?)`

    // Удалите функцию `didLoadDataFromServer()`
    
    // Удалите функцию `didFailToLoadData(with error: Error)`
        
    // MARK: - QuestionFactoryDelegate
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
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
       
        presenter.noButtonClicked()
    }
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
  
        presenter.yesButtonClicked()
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAlert(viewModel: AlertModel) {
        alertPresener?.show(model: viewModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor//
        noButton.isEnabled = false
        yesButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return } //разворачиваем слабую ссылку
            self.presenter.showNextQuestionOrResults()
            
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
}
