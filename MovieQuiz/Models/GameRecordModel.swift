//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by Vladislav Mishukov on 03.08.2023.
//

import Foundation

struct GameRecord: Codable, Comparable{
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
    
    let correct: Int
    let total: Int
    let date: Date
    
  
}
