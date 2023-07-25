//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Vladislav Mishukov on 20.07.2023.
//

import Foundation

class QuestionFactory : QuestionFactoryProtocol {
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
    
    func requestNextQuestion() -> QuizQuestion? {
        guard let index = (0..<questions.count).randomElement() else {
            return nil
        }
        return questions[safe: index]
    }
    
}
