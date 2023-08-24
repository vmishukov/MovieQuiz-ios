import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // переменная с индексом текущего вопроса, начальное значение 0
    private var correctAnswers = 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0

    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let presenter = MovieQuizPresenter()
    private var alertPresener: AlertPresenterProtocol?
    private var statisticService: StatisticService?    
    // MARK: - Lifecycle
    
  
    // константа с кнопкой для системного алерта
    override func viewDidLoad() {
        alertPresener = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.cornerRadius = 20 // радиус скругления картинки
        imageView.layer.borderColor = UIColor.clear.cgColor
        super.viewDidLoad()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    func didLoadDataFromServer() {
        hideLoadingIndicator() // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    // MARK: - QuestionFactoryDelegate
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let viewModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion:  {[weak self] in
                guard let self = self else { return }

                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            })
        
        alertPresener?.show(model: viewModel)
        // создайте и покажите алерт
    }
    
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { // 1
            correctAnswers += 1 // 2
        }
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor//
        noButton.isEnabled = false
        yesButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return } //разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if self.presenter.isLastQuestion(){
            // идём в состояние "Результат квиза"
            statisticService?.store(correct: correctAnswers, total: self.presenter.questionsAmount)
            
            let gamesCount = statisticService?.gamesCount ?? 0
            let correct = statisticService?.bestGame.correct ?? 0
            let total = statisticService?.bestGame.total ?? 0
            let date = statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString
            let totalAccuracy = String(format: "%.2f", statisticService?.totalAccuracy ?? 0)
            
            let text = /*correctAnswers == questionsAmount ?
                        "Поздравляем, Вы ответили на 10 из 10!" :*/
            "Ваш результат: \(correctAnswers)/\(self.presenter.questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд \(correct)/\(total) (\(date))\nСредняя точность \(totalAccuracy)%"
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion:  {[weak self] in
                    guard let self = self else { return }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                })
            alertPresener?.show(model: viewModel)
            correctAnswers = 0
        } else {
            //следующий вопрос
            self.presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
