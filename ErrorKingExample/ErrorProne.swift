//
//  ErrorProne.swift
//  ErrorKing
//
//  Created by Bruno Rocha on 8/13/16.
//  Copyright © 2016 Bruno Rocha. All rights reserved.
//

import Foundation
import UIKit

protocol NibLoadable {}

extension NibLoadable where Self: UIView {
    static func loadFromNib() -> Self {
        // The view class should have the same name as the xib filename, e.g.: MyView and MyView.xib
        if let nibName = nibName() {
            let nib = UINib(nibName: nibName, bundle: nil)
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

extension UIViewController {
    var isVisible: Bool {
        return self.isViewLoaded() && self.view.window != nil
    }
}

protocol ErrorKingEmptyStateType: class {
    func reloadData()
}

extension ErrorKing: ErrorKingEmptyStateType {
    final func reloadData() {
        originalVC?.emptyStateReloadButtonTouched()
    }
}

public class ErrorKing {
    private (set) weak var originalVC: UIViewController?
    private (set) var shouldDisplayError = false
    private (set) var storedError: NSError?
    private (set) var storedTitle: String = ""
    private (set) var storedDescription: String = ""
    private var emptyStateView: ErrorKingEmptyStateView = ErrorKingEmptyStateView.loadFromNib()
    
    private init () {}
    
    final private func setup(owner: UIViewController) {
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
    
    final func setError(error: NSError?) {
        shouldDisplayError = true
        storedError = error
    }
    
    final func displayErrorIfNeeded() {
        guard shouldDisplayError else { return }
        displayError(storedTitle, description: storedDescription)
    }
    
    final private func displayError(title: String, description: String) {
        guard let error = storedError where originalVC?.isVisible == true else {
            return
        }
        emptyStateView.errorLabel?.text = description
        shouldDisplayError = false
        storedError = nil
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = OLErrorController(title: title, message: description)
            let handler: ErrorKingVoidHandler = { _ in
                self.prepareEmptyState()
            }
            alertController.addButtonAndHandler(nil)
            self.originalVC?.presentViewController(alertController.alert, animated: true, completion: handler)
        })
    }
    
    final private func prepareEmptyState() {
        originalVC?.actionBeforeDisplayingEmptyState()
    }
    
    final private func actionBeforeDisplayingEmptyState() {
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
    
    final private func emptyStateReloadButtonTouched() {
        emptyStateView.hidden = true
    }
}

extension UIViewController {
    private struct AssociatedKeys {
        static var DescriptiveName = "nsh_DescriptiveName"
    }
    var errorKing: ErrorKing! {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? ErrorKing
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.DescriptiveName,
                    newValue as ErrorKing?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}

extension UIViewController {
    public override class func initialize() {
        struct Static {
            static var loadToken: dispatch_once_t = 0
            static var appearToken: dispatch_once_t = 0
        }
        
        if self !== UIViewController.self {
            return
        }
        
        dispatch_once(&Static.loadToken) {
            let originalSelector = Selector("viewDidLoad")
            let swizzledSelector = Selector("ek_viewDidLoad")
            
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
            let originalSelector = Selector("viewDidAppear:")
            let swizzledSelector = Selector("ek_viewDidAppear:")
            
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
    
    func ek_viewDidAppear(animated: Bool) {
        self.ek_viewDidAppear(animated)
        self.errorKing.displayErrorIfNeeded()
    }
    
    func ek_viewDidLoad() {
        self.ek_viewDidLoad()
        self.errorKing = ErrorKing()
        self.errorKing.setup(self)
    }
    
    //
    
    func actionBeforeDisplayingEmptyState() {
        self.errorKing.actionBeforeDisplayingEmptyState()
    }
    
    func emptyStateReloadButtonTouched() {
        self.errorKing.emptyStateReloadButtonTouched()
    }
}

/*class OLErrorCoordinator {
    private (set) weak var originalVC: UIViewController?
    private (set) var shouldDisplayError = false
    private (set) var storedError: NSError?
    private let emptyStateView: OLEmptyStateView
    private var filterEmptyStateView: OLFilterEmptyStateView? = nil
    
    init(owner: UIViewController) {
        emptyStateView = OLEmptyStateView.loadFromNib()
        emptyStateView.coordinator = self
        emptyStateView.frame = owner.view.frame
        emptyStateView.layoutIfNeeded()
        emptyStateView.hidden = true
        owner.view.addSubview(emptyStateView)
        originalVC = owner
        guard owner as? OLCalendarViewController != nil else {
            return
        }
        let filterEmptyState = OLFilterEmptyStateView.loadFromNib()
        filterEmptyState.coordinator = self
        filterEmptyState.frame = owner.view.frame
        filterEmptyState.layoutIfNeeded()
        filterEmptyState.hidden = true
        owner.view.addSubview(filterEmptyState)
        filterEmptyStateView = filterEmptyState
    }
    
    final private func displayError() {
        guard let error = storedError where originalVC?.isVisible == true else {
            return
        }
        let description = olympicsDescriptionFor(error: error, mode: .Alert)
        emptyStateView.errorLabel?.text = olympicsDescriptionFor(error: error, mode: .EmptyState)
        shouldDisplayError = false
        storedError = nil
        dispatch_async(dispatch_get_main_queue(), {
            MBProgressHUD.hideHUDForView(self.originalVC?.view, animated: false)
            let alertController = OLErrorController(title: "Erro \(olympicsErrorCodeFor(error: error))", message: description)
            let handler: OLErrorVoidHandler = { _ in
                self.prepareEmptyState()
            }
            alertController.addButtonAndHandler(nil)
            self.originalVC?.presentViewController(alertController.alert, animated: true, completion: handler)
        })
    }
    
    final func setError(error: NSError?, client: OLHTTPClient) {
        client.attempts = 0
        shouldDisplayError = true
        storedError = error
    }
    
    final func displayErrorIfAvailable() {
        guard shouldDisplayError else { return }
        displayError()
    }
    
    final private func prepareEmptyState() {
        actionBeforeDisplayingEmptyState()
    }
    
    final func displayEmptyState() {
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
    
    final func displayFilterEmptyState() {
        guard let originalVC = originalVC else {
            return
        }
        originalVC.view.userInteractionEnabled = true
        filterEmptyStateView?.alpha = 0
        filterEmptyStateView?.hidden = false
        UIView.animateWithDuration(0.5) {
            self.filterEmptyStateView?.alpha = 1.0
        }
    }
    
    final func setEmptyStateFrame(rect: CGRect) {
        emptyStateView.frame = rect
    }
    
    func actionBeforeDisplayingEmptyState() {
        displayEmptyState()
    }
    
    func actionBeforeDisplayingFilterEmptyState() {
        displayFilterEmptyState()
    }
    
    func emptyStateReloadButtonTouched() {
        emptyStateView.hidden = true
        filterEmptyStateView?.hidden = true
    }
}

extension OLErrorCoordinator: OLErrorCoordinatorEmptyStateType {
    final func reloadData() {
        emptyStateReloadButtonTouched()
    }
}*/
