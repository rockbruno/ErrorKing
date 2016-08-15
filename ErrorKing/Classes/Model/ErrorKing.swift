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
    private (set) var storedData: ErrorKingStoredData = ErrorKingStoredData()
    private var emptyStateView: ErrorKingEmptyStateView?
    
    struct ErrorKingStoredData {
        private var title = ""
        private var description = ""
        private var emptyStateText = ""
        private var shouldDisplayError = false
    }
    
    init () {}
    
    final func setup(owner: UIViewController) {
        originalVC = owner
        setEmptyStateView(toView: ErrorKingEmptyStateView.loadFromNib())
    }
    
    final public func setEmptyStateView(toView view: ErrorKingEmptyStateView) {
        guard let originalVC = originalVC else {
            return
        }
        let emptyStateView = view
        emptyStateView.coordinator = self
        emptyStateView.frame = originalVC.view.frame
        emptyStateView.layoutIfNeeded()
        emptyStateView.hidden = true
        emptyStateView.removeFromSuperview()
        originalVC.view.addSubview(emptyStateView)
        self.emptyStateView = emptyStateView
    }
    
    final public func setEmptyStateFrame(rect: CGRect) {
        emptyStateView?.frame = rect
    }
    
    final public func setError(title title: String, description: String, emptyStateText: String) {
        storedData.shouldDisplayError = true
        storedData.title = title
        storedData.description = description
        storedData.emptyStateText = emptyStateText
        displayErrorIfNeeded()
    }
    
    final private func displayErrorIfNeeded() {
        guard storedData.shouldDisplayError else { return }
        displayError(storedData.title, description: storedData.description)
    }
    
    final private func displayError(title: String, description: String) {
        guard originalVC?.isVisible == true else {
            return
        }
        emptyStateView?.errorLabel?.text = storedData.emptyStateText
        storedData.shouldDisplayError = false
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
    
    final public func actionBeforeDisplayingErrorKingEmptyState() {
        displayEmptyState()
    }
    
    final private func displayEmptyState() {
        guard let originalVC = originalVC else {
            return
        }
        originalVC.view.userInteractionEnabled = true
        emptyStateView?.alpha = 0
        emptyStateView?.hidden = false
        UIView.animateWithDuration(0.5) {
            self.emptyStateView?.alpha = 1.0
        }
    }
    
    final public func errorKingEmptyStateReloadButtonTouched() {
        emptyStateView?.hidden = true
    }
}

extension UIViewController {
    var isVisible: Bool {
        return self.isViewLoaded() && self.view.window != nil
    }
}
