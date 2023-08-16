//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Vladislav Mishukov on 20.07.2023.
//

import Foundation

class QuestionFactory : QuestionFactoryProtocol {

    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    /*
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather",
                     corrcetAnswer: true),
        QuizQuestion(image: "The Dark Knight",
                     corrcetAnswer: true),
        QuizQuestion(image: "Kill Bill",
                     corrcetAnswer: true),
        QuizQuestion(image: "The Avengers",
                     corrcetAnswer: true),
        QuizQuestion(image: "Deadpool",
                     corrcetAnswer: true),
        QuizQuestion(image: "The Green Knight",
                     corrcetAnswer: true),
        QuizQuestion(image: "Old",
                     corrcetAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                     corrcetAnswer: false),
        QuizQuestion(image: "Tesla",
                     corrcetAnswer: false),
        QuizQuestion(image: "Vivarium",
                     corrcetAnswer: false)
    ]
    */

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
}
