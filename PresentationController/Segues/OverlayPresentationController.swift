//
//  OverlayPresentationController.swift
//  AllIWantFor
//
//  Created by Michael Nino Evensen on 13/09/2017.
//  Copyright © 2017 Michael Evensen. All rights reserved.
//

import UIKit

class OverlayPresentationController: UIPresentationController {
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    }()
    
    fileprivate var isTransitioning = true
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapDimming(_:)))
    }
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let frame = containerView?.bounds ?? .zero
        switch presentedViewController.modalTransitionStyle {
        case .coverVertical:
            if presentedViewController.preferredContentSize != .zero {
                return frame.divided(atDistance: presentedViewController.preferredContentSize.height, from: .maxYEdge).slice
            } else {
                return frame
            }
        case .crossDissolve:
            if presentedViewController.preferredContentSize != .zero {
                let size = presentedViewController.preferredContentSize
                let origin = CGPoint(
                    x: (frame.width - size.width) / 2,
                    y: (frame.height - size.height) / 2
                )
                return CGRect(origin: origin, size: size)
            } else {
                return frame
            }
        case .flipHorizontal, .partialCurl:
            fatalError()
        }
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        isTransitioning = true
        
        let frame = containerView?.bounds ?? .zero
        
        dimmingView.frame = frame
        dimmingView.alpha = 0
        containerView?.insertSubview(dimmingView, at: 0)
        
        
        containerView?.clipsToBounds = true
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [dimmingView, presentingViewController] context in
            dimmingView.alpha = 1
            presentingViewController.view.tintAdjustmentMode = .dimmed
            }, completion: { context in
                
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.addGestureRecognizer(tapGestureRecognizer)
        } else {
            dimmingView.removeFromSuperview()
        }
        
        isTransitioning = false
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        isTransitioning = true
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [dimmingView, presentingViewController] context in
            dimmingView.alpha = 0
            presentingViewController.view.tintAdjustmentMode = .automatic
            }, completion: { context in
                
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            dimmingView.removeGestureRecognizer(tapGestureRecognizer)
            dimmingView.removeFromSuperview()
        }
        isTransitioning = false
    }
    
    @objc func didTapDimming(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .ended:
            presentingViewController.dismiss(animated: true, completion: nil)
        case _:
            break
        }
    }
}

extension OverlayPresentationController {
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        guard !isTransitioning else { return }
        
        let frame = frameOfPresentedViewInContainerView
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.presentedView?.frame = frame
        },
            completion: nil
        )
    }
}
