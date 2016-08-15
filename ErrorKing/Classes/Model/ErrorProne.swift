//
//  ErrorProne.swift
//  ErrorKing
//
//  Created by Bruno Rocha on 8/13/16.
//  Copyright © 2016 Bruno Rocha. All rights reserved.
//

import Foundation
import UIKit

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

public extension UIViewController {
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
