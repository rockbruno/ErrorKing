//
//  OLErrorController.swift
//  ClaroSports
//
//  Created by Bruno Rocha on 7/13/16.
//  Copyright © 2016 Movile. All rights reserved.
//

import UIKit

typealias ErrorKingVoidHandler = (() -> Void)
typealias ErrorKingActionHandler = ((UIAlertAction) -> Void)

final class ErrorKingAlertController {
    let alert: UIAlertController
    
    init(title: String, message: String) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addButtonAndHandler(_ handler: ErrorKingActionHandler?) {
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
    }
}
