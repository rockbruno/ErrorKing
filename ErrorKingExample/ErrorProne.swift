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
    var errorKing: ErrorKing? { get set }
    func actionBeforeDisplayingErrorKingEmptyState()
    func errorKingEmptyStateReloadButtonTouched()
}

extension UIViewController {
    private struct AssociatedKeys {
        static var DescriptiveName = "ek_DescriptiveName"
    }
    var isVisible: Bool {
        return self.isViewLoaded() && self.view.window != nil
    }
}

extension ErrorProne where Self: UIViewController {
    var errorKing: ErrorKing? {
        get {
            return objc_getAssociatedObject(self, &Self.AssociatedKeys.DescriptiveName) as? ErrorKing
        } set {
            guard let newValue = newValue else {
                return
            }
            objc_setAssociatedObject(self, &Self.AssociatedKeys.DescriptiveName, newValue as ErrorKing?,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func actionBeforeDisplayingErrorKingEmptyState() {
        errorKing?.actionBeforeDisplayingErrorKingEmptyState()
    }
    
    func errorKingEmptyStateReloadButtonTouched() {
        errorKing?.errorKingEmptyStateReloadButtonTouched()
    }
}

extension UIViewController {
    override public class func initialize() {
        guard self === UIViewController.self else {
            return
        }
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
    
    // MARK: - Method Swizzling
    
    func ek_viewDidLoad() {
        self.ek_viewDidLoad()
        guard let errorProneController = self as? ErrorProne else {
            return
        } //I can't check this on the initialize() method. It used to work before but now it throws an unknown compile error - maybe because I added :class to the protocol?
        let errorKing = ErrorKing()
        errorKing.setup(self)
        errorProneController.errorKing = errorKing
    }
    
    func ek_viewDidAppear(animated: Bool) {
        self.ek_viewDidAppear(animated)
        guard let errorProneController = self as? ErrorProne else {
            return
        }
        errorProneController.errorKing?.displayErrorIfNeeded()
    }
}
