//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Vladislav Mishukov on 25.07.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
