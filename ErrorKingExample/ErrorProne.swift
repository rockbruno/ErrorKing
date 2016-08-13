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

extension ErrorProne where Self: UIViewController {
    var errorKing: ErrorKing? {
        get {
            return objc_getAssociatedObject(self, &Self.AssociatedKeys.DescriptiveName) as? ErrorKing
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &Self.AssociatedKeys.DescriptiveName,
                    newValue as ErrorKing?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
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
    private struct AssociatedKeys {
        static var DescriptiveName = "ek_DescriptiveName"
    }
    var isVisible: Bool {
        return self.isViewLoaded() && self.view.window != nil
    }
}

extension UIViewController {
    
    override public class func initialize() {
        if self !== UIViewController.self {
            return
        }

        struct Static {
            static var loadToken: dispatch_once_t = 0
            static var appearToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.loadToken) {
            let originalSelector = #selector(UIViewController.viewDidLoad)
            let swizzledSelector = #selector(UIViewController.ek_viewDidLoad)
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
        
        dispatch_once(&Static.appearToken) {
            let originalSelector = #selector(UIViewController.viewDidAppear(_:))
            let swizzledSelector = #selector(UIViewController.ek_viewDidAppear(_:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
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