//
//  ErrorProne.swift
//  ErrorKing
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
    private weak var originalVC: UIViewController?
    private var storedData: ErrorKingStoredData = ErrorKingStoredData()
    private var emptyStateView: ErrorKingEmptyStateView?
    
    private struct ErrorKingStoredData {
        private var title = ""
        private var description = ""
        private var emptyStateText = ""
        private var shouldDisplayError = false
    }
    
    private init () {}
    
    final private func setup(owner: UIViewController) {
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

//MARK: ErrorProne Protocol

public protocol ErrorProne: class {
    var errorKing: ErrorKing? { get }
    func actionBeforeDisplayingErrorKingEmptyState()
    func errorKingEmptyStateReloadButtonTouched()
}

private extension UIViewController {
    private struct AssociatedKeys {
        static var EKDescriptiveName = "ek_DescriptiveName"
    }
}

public extension ErrorProne where Self: UIViewController {
    var errorKing: ErrorKing? {
        return objc_getAssociatedObject(self, &Self.AssociatedKeys.EKDescriptiveName) as? ErrorKing
    }
    
    func actionBeforeDisplayingErrorKingEmptyState() {
        errorKing?.actionBeforeDisplayingErrorKingEmptyState()
    }
    
    func errorKingEmptyStateReloadButtonTouched() {
        errorKing?.errorKingEmptyStateReloadButtonTouched()
    }
}

private extension UIViewController {
    override public class func initialize() {
        guard self === UIViewController.self else {
            return
        }
        //I can't check for protocol conformance on initialize() without losing the ability to provide default implementations. For now, all view controllers get swizzled, although only ErrorProne ones do anything at all.
        struct Static {
            static var loadToken: dispatch_once_t = 0
            static var appearToken: dispatch_once_t = 0
        }
        swizzle(#selector(UIViewController.viewDidLoad), new: #selector(UIViewController.ek_viewDidLoad), token: &Static.loadToken)
        swizzle(#selector(UIViewController.viewDidAppear(_:)), new: #selector(UIViewController.ek_viewDidAppear(_:)), token: &Static.appearToken)
    }
    
    private class func swizzle(original: Selector, new: Selector, inout token: dispatch_once_t) {
        dispatch_once(&token) {
            let originalMethod = class_getInstanceMethod(self, original)
            let swizzledMethod = class_getInstanceMethod(self, new)
            let didAddMethod = class_addMethod(self, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            guard didAddMethod else {
                return method_exchangeImplementations(originalMethod, swizzledMethod)
            }
            class_replaceMethod(self, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        }
    }
    
    @objc private func ek_viewDidLoad() {
        self.ek_viewDidLoad()
        guard let _ = self as? ErrorProne else {
            return
        }
        let errorKing = ErrorKing()
        errorKing.setup(self)
        objc_setAssociatedObject(self, &AssociatedKeys.EKDescriptiveName, errorKing, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func ek_viewDidAppear(animated: Bool) {
        self.ek_viewDidAppear(animated)
        guard let errorProneController = self as? ErrorProne else {
            return
        }
        errorProneController.errorKing?.displayErrorIfNeeded()
    }
}
