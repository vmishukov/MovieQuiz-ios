//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Vladislav Mishukov on 26.07.2023.
//

import UIKit
class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
    
    func show(model: AlertModel) {
        let alert = UIAlertController(
            title: model.message,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        (delegate)?.present(alert, animated: true, completion: nil)
    }
}
