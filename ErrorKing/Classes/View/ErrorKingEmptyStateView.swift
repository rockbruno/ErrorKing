//
//  OLEmptyStateView.swift
//  ClaroSports
//
//  Created by Bruno Rocha on 7/13/16.
//  Copyright © 2016 Movile. All rights reserved.
//

import UIKit

public class ErrorKingEmptyStateView: UIView {
    @IBOutlet weak var errorLabel: UILabel?
    weak var coordinator: ErrorKingEmptyStateType?
    
    @IBAction func tryAgain(sender: AnyObject) {
        coordinator?.reloadData()
    }
}

extension ErrorKingEmptyStateView: ErrorKingNibLoadable {}
