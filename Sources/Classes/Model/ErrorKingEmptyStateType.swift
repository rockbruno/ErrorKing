//
//  ErrorKingEmptyStateType.swift
//  ErrorKing
//
//  Created by Bruno Rocha on 4/4/17.
//  Copyright © 2017 Movile. All rights reserved.
//

import Foundation

protocol ErrorKingEmptyStateType: class {
    func reloadData()
}

extension ErrorKing: ErrorKingEmptyStateType {
    func reloadData() {
        (originalVC as? ErrorProne)?.errorKingEmptyStateReloadButtonTouched()
    }
}
