//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Vladislav Mishukov on 24.08.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert(viewModel: AlertModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func nextQuestionClearence()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}


final class MovieQuizPresenter: QuestionFactoryDelegate {

    private var statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert (model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ??  UIImage(),
            question: model.text,
            questionNumber:"\(currentQuestionIndex+1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    
    
    func didAnswer(isCorrectAnswer: Bool){
        if isCorrectAnswer { // 1
            correctAnswers += 1 // 2
        }
    }
    
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return } //разворачиваем слабую ссылку
            self.proceedToNextQuestionOrResults()
            viewController?.nextQuestionClearence()
            
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion(){
            // идём в состояние "Результат квиза"
            self.statisticService?.store(correct: self.correctAnswers, total: self.questionsAmount)
            
            //Не вынес создание сообщения в отдельную функцию по причине KISS/YAGNI
            let gamesCount = self.statisticService?.gamesCount ?? 0
            let correct = self.statisticService?.bestGame.correct ?? 0
            let total = self.statisticService?.bestGame.total ?? 0
            let date = self.statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString
            let totalAccuracy = String(format: "%.2f", self.statisticService?.totalAccuracy ?? 0)
            
            let text =
            "Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд \(correct)/\(total) (\(date))\nСредняя точность \(totalAccuracy)%"
            //Не вынес создание сообщения в отдельную функцию по причине KISS/YAGNI
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion:  {[weak self] in
                    guard let self = self else { return }
                    self.restartGame()
                })
            viewController?.showAlert(viewModel: viewModel)
            self.correctAnswers = 0
        } else {
            //следующий вопрос
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
