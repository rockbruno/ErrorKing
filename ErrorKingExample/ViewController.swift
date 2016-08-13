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
        self.errorKing.setError(NSError(domain: " asd", code: 3, userInfo: nil))
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController {
    override func actionBeforeDisplayingEmptyState() {
        super.actionBeforeDisplayingEmptyState()
    }
}
