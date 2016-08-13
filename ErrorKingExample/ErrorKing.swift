//
//  ErrorKing.swift
//  ErrorKingExample
//
//  Created by Bruno Rocha on 8/13/16.
//  Copyright © 2016 Bruno Rocha. All rights reserved.
//

import Foundation
import UIKit

protocol ErrorKingEmptyStateType: class {
    func reloadData()
}

extension ErrorKing: ErrorKingEmptyStateType {
    final func reloadData() {
        (originalVC as? ErrorProne)?.errorKingEmptyStateReloadButtonTouched()
    }
}

public class ErrorKing {
    private (set) weak var originalVC: UIViewController?
    private (set) var shouldDisplayError = false
    private (set) var storedTitle: String = ""
    private (set) var storedDescription: String = ""
    private var emptyStateView: ErrorKingEmptyStateView = ErrorKingEmptyStateView.loadFromNib()
    
    init () {}
    
    final func setup(owner: UIViewController) {
        originalVC = owner
        setEmptyStateView(toView: ErrorKingEmptyStateView.loadFromNib())
        owner.view.addSubview(emptyStateView)
    }
    
    final func setEmptyStateView(toView view: ErrorKingEmptyStateView) {
        guard let originalVC = originalVC else {
            return
        }
        emptyStateView = view
        emptyStateView.coordinator = self
        emptyStateView.frame = originalVC.view.frame
        emptyStateView.layoutIfNeeded()
        emptyStateView.hidden = true
    }
    
    final func setEmptyStateFrame(rect: CGRect) {
        emptyStateView.frame = rect
    }
    
    final func setError(title title: String, description: String) {
        shouldDisplayError = true
        storedTitle = title
        storedDescription = description
        displayErrorIfNeeded()
    }
    
    final func displayErrorIfNeeded() {
        guard shouldDisplayError else { return }
        displayError(storedTitle, description: storedDescription)
    }
    
    final private func displayError(title: String, description: String) {
        guard originalVC?.isVisible == true else {
            return
        }
        emptyStateView.errorLabel?.text = description
        shouldDisplayError = false
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = ErrorKingAlertController(title: title, message: description)
            let handler: ErrorKingVoidHandler = { _ in
                self.prepareEmptyState()
            }
            alertController.addButtonAndHandler(nil)
            self.originalVC?.presentViewController(alertController.alert, animated: true, completion: handler)
        })
    }
    
    final private func prepareEmptyState() {
        (originalVC as? ErrorProne)?.actionBeforeDisplayingErrorKingEmptyState()
    }
    
    final func actionBeforeDisplayingErrorKingEmptyState() {
        displayEmptyState()
    }
    
    final private func displayEmptyState() {
        guard let originalVC = originalVC else {
            return
        }
        originalVC.view.userInteractionEnabled = true
        emptyStateView.alpha = 0
        emptyStateView.hidden = false
        UIView.animateWithDuration(0.5) {
            self.emptyStateView.alpha = 1.0
        }
    }
    
    final func errorKingEmptyStateReloadButtonTouched() {
        emptyStateView.hidden = true
    }
}
