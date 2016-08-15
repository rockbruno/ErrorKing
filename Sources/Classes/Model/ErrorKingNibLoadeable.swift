//
//  ErrorKingNibLoadeable.swift
//  ErrorKingExample
//
//  Created by Bruno Rocha on 8/13/16.
//  Copyright © 2016 Bruno Rocha. All rights reserved.
//

import UIKit

protocol ErrorKingNibLoadable {}

extension ErrorKingNibLoadable where Self: UIView {
    static func loadFromNib() -> Self {
        // The view class should have the same name as the xib filename, e.g.: MyView and MyView.xib
        if let nibName = nibName() {
            let nib = UINib(nibName: nibName, bundle: NSBundle(forClass: Self.self))
            if let view = nib.instantiateWithOwner(self, options: nil).first as? Self {
                return view
            }
        }
        
        fatalError("\(self) does not have a nib with the same name!")
    }
    
    static func nibName() -> String? {
        // self can print the module, e.g.: Module.MyView
        // we extract the last piece to make sure we are using the correct name
        return "\(self)".characters.split{$0 == "."}.map(String.init).last
    }
}
