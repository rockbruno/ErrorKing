//
//  OLEmptyStateView.swift
//  ClaroSports
//
//  Created by Bruno Rocha on 7/13/16.
//  Copyright © 2016 Movile. All rights reserved.
//

import UIKit

open class ErrorKingEmptyStateView: UIView {
    @IBOutlet weak var errorLabel: UILabel?
    weak var coordinator: ErrorKingEmptyStateType?
    
    func setup() {
        //We don't use an init so people can make custom empty states from the Storyboard.
        backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        let errorLabel = UILabel()
        errorLabel.font = UIFont.systemFont(ofSize: 20)
        errorLabel.textColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        errorLabel.text = "#error_description"
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 57)
        ])
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no_connection", in: Bundle(for: ErrorKingEmptyStateView.self) , compatibleWith: nil)
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            imageView.heightAnchor.constraint(equalToConstant: 170),
            imageView.bottomAnchor.constraint(equalTo: errorLabel.topAnchor, constant: -18)
        ])
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.textAlignment = .center
        addSubview(retryButton)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(tryAgain(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            retryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            retryButton.heightAnchor.constraint(equalToConstant: 55),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: -5)
        ])
        self.errorLabel = errorLabel
    }
    
    @IBAction func tryAgain(_ sender: AnyObject) {
        coordinator?.reloadData()
    }
}
