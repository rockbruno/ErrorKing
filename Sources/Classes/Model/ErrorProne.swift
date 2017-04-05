//
//  ErrorProne.swift
//  ErrorKing
//
//  Created by Bruno Rocha on 8/13/16.
//  Copyright © 2016 Bruno Rocha. All rights reserved.
//

import Foundation
import UIKit

open class ErrorKing {
    weak var originalVC: UIViewController?
    fileprivate var storedData: ErrorKingStoredData = ErrorKingStoredData()
    fileprivate var emptyStateView: ErrorKingEmptyStateView?
    
    fileprivate struct ErrorKingStoredData {
        fileprivate var title = ""
        fileprivate var description = ""
        fileprivate var emptyStateText = ""
        fileprivate var shouldDisplayError = false
    }
    
    fileprivate init () {}
    
    final fileprivate func setup(owner: ErrorProne) {
        originalVC = owner as? UIViewController
        let emptyState = ErrorKingEmptyStateView()
        emptyState.setup()
        setEmptyStateView(toView: emptyState)
    }
    
    final public func setEmptyStateView(toView view: ErrorKingEmptyStateView) {
        guard let originalVC = originalVC else {
            return
        }
        let emptyStateView = view
        emptyStateView.coordinator = self
        emptyStateView.frame = originalVC.view.frame
        emptyStateView.layoutIfNeeded()
        emptyStateView.isHidden = true
        emptyStateView.removeFromSuperview()
        originalVC.view.addSubview(emptyStateView)
        self.emptyStateView = emptyStateView
    }
    
    final public func setEmptyStateFrame(_ rect: CGRect) {
        emptyStateView?.frame = rect
    }
    
    final public func setError(title: String, description: String, emptyStateText: String) {
        storedData.shouldDisplayError = true
        storedData.title = title
        storedData.description = description
        storedData.emptyStateText = emptyStateText
        displayErrorIfNeeded()
    }
    
    final public func displayErrorIfNeeded() {
        guard storedData.shouldDisplayError else { return }
        displayError(storedData.title, description: storedData.description)
    }
    
    final fileprivate func displayError(_ title: String, description: String) {
        guard originalVC?.isVisible == true else {
            return
        }
        emptyStateView?.errorLabel?.text = storedData.emptyStateText
        storedData.shouldDisplayError = false
        DispatchQueue.main.async { [weak self] in
            let alertController = ErrorKingAlertController(title: title, message: description)
            let handler: ErrorKingVoidHandler = { _ in
                self?.prepareEmptyState()
            }
            alertController.addButtonAndHandler(nil)
            self?.originalVC?.present(alertController.alert, animated: true, completion: handler)
        }
    }
    
    final fileprivate func prepareEmptyState() {
        (originalVC as? ErrorProne)?.actionBeforeDisplayingErrorKingEmptyState()
    }
    
    final public func actionBeforeDisplayingErrorKingEmptyState() {
        displayEmptyState()
    }
    
    final fileprivate func displayEmptyState() {
        guard let originalVC = originalVC else {
            return
        }
        originalVC.view.isUserInteractionEnabled = true
        emptyStateView?.alpha = 0
        emptyStateView?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.emptyStateView?.alpha = 1.0
        }) 
    }
    
    final public func errorKingEmptyStateReloadButtonTouched() {
        emptyStateView?.isHidden = true
    }
}

extension UIViewController {
    var isVisible: Bool {
        return self.isViewLoaded && self.view.window != nil
    }
}

//MARK: ErrorProne Protocol

public protocol ErrorProne: class {
    func actionBeforeDisplayingErrorKingEmptyState()
    func errorKingEmptyStateReloadButtonTouched()
}

private extension UIViewController {
    struct AssociatedKeys {
        static var EKDescriptiveName = "ek_DescriptiveName"
    }
}

public extension ErrorProne where Self: UIViewController {
    var errorKing: ErrorKing {
        guard let object = objc_getAssociatedObject(self, &Self.AssociatedKeys.EKDescriptiveName) as? ErrorKing else {
            let ek = ErrorKing()
            ek.setup(owner: self)
            objc_setAssociatedObject(self, &AssociatedKeys.EKDescriptiveName, ek, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return ek
        }
        return object
    }

    func actionBeforeDisplayingErrorKingEmptyState() {
        errorKing.actionBeforeDisplayingErrorKingEmptyState()
    }
    
    func errorKingEmptyStateReloadButtonTouched() {
        errorKing.errorKingEmptyStateReloadButtonTouched()
    }
}
