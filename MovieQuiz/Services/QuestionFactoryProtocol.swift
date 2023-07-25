//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Vladislav Mishukov on 24.07.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
