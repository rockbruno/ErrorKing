//
//  ViewController.swift
//  ErrorKingExample
//
//  Created by Bruno Rocha on 8/13/16.
//  Copyright © 2016 Bruno Rocha. All rights reserved.
//

import UIKit
import ErrorKing

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    //Uncomment these to show a custom Empty State View.
    //=======
        //let myCustomEmptyState = Bundle.main.loadNibNamed("ACustomView", owner:self, options:nil)?[0] as! ErrorKingEmptyStateView
        //errorKing?.setEmptyStateView(toView: myCustomEmptyState)
    //========
        errorKing.setError(title: "Damn!", description: "Sorry for that.", emptyStateText: "Something happened :(")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        errorKing.displayErrorIfNeeded()
    }
}

extension ViewController: ErrorProne {
    func actionBeforeDisplayingErrorKingEmptyState() {
        errorKing.actionBeforeDisplayingErrorKingEmptyState()
    }
    func errorKingEmptyStateReloadButtonTouched() {
        print("Reload Button Touched")
        errorKing.errorKingEmptyStateReloadButtonTouched()
    }
}
