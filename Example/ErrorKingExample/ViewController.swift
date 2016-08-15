//
//  ViewController.swift
//  ErrorKingExample
//
//  Created by Bruno Rocha on 8/13/16.
//  Copyright © 2016 Bruno Rocha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    //Uncomment these to show a custom Empty State View.
    //=======
        //let myCustomEmptyState = ACustomView.loadFromNib()
        //self.errorKing?.setEmptyStateView(toView: myCustomEmptyState)
    //========
        self.errorKing?.setError(title: "Damn!", description: "Sorry for that.", emptyStateText: "Something happened :(")
    }
}

extension ViewController: ErrorProne {
    func actionBeforeDisplayingErrorKingEmptyState() {
        errorKing?.actionBeforeDisplayingErrorKingEmptyState()
    }
    func errorKingEmptyStateReloadButtonTouched() {
        print("Reload Button Touched")
        errorKing?.errorKingEmptyStateReloadButtonTouched()
    }
}
