//
//  SlideInPresentationController.swift
//  PresentationController
//
//  Created by Michael Nino Evensen on 12/11/2019.
//  Copyright © 2019 Michael Nino Evensen. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {
    
    private var dimmingView: UIView!
    private var direction: PresentationDirection

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, direction: PresentationDirection) {
        self.direction = direction
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        // Configure dimming view
        self.setupDimmingView()
    }
    
    override func presentationTransitionWillBegin() {
        
        guard let dimmingView = self.dimmingView else { return }
        
        // Insert dimming view
        self.containerView?.insertSubview(dimmingView, at: 0)

        // Add layout
//        NSLayoutConstraint.activate(
//          NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
//            options: [], metrics: nil, views: ["dimmingView": dimmingView]))
//        NSLayoutConstraint.activate(
//          NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
//            options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        
        guard let containerView = self.containerView else { return }
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        ])

        // Animate in dimming view on presentationTransitionWillBegin()
        guard let coordinator = self.presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        /*
            transitionCoordinator of UIPresentationController has a very cool method to animate things during the transition. In this section, you set the dimming view’s alpha to 1.0 along with the presentation transition.
         */
        coordinator.animate(alongsideTransition: { (_) in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        
        // Animate out dimming view on dismissalTransitionWillBegin()
        guard let coordinator = self.presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { (_) in
           self.dimmingView.alpha = 0.0
       })
    }
    
    /// Respond to layout changes in the presentation controller’s containerView.
    override func containerViewDidLayoutSubviews() {
        
        // Here you reset the presented view’s frame to fit any changes to the containerView frame.
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    /*
     This method receives the content container and parent view’s size, and then it calculates the size for the presented content. In this code, you restrict the presented view to 2/3 of the screen by returning 2/3 the width for horizontal and 2/3 the height for vertical presentations.
     */
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch direction {
        case .left, .right:
            return CGSize(width: parentSize.width * (2.0 / 3.0), height: parentSize.height)
        case .bottom, .top:
            return CGSize(width: parentSize.width, height: parentSize.height * (2.0 / 3.0))
        }
    }
    
    /*
     You declare a frame and give it the size calculated in size(forChildContentContainer:withParentContainerSize:).
     For .right and .bottom directions, you adjust the origin by moving the x origin (.right) and y origin (.bottom) 1/3 of the width or height.
     */
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = self.size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)

        switch direction {
        case .right:
          frame.origin.x = containerView!.frame.width * (1.0 / 3.0)
        case .bottom:
          frame.origin.y = containerView!.frame.height * (1.0 / 3.0)
        default:
          frame.origin = .zero
        }
        return frame
    }
}


// MARK: - Dimming View
private extension SlideInPresentationController {
  
    func setupDimmingView() {
        self.dimmingView = UIView()
        self.dimmingView.translatesAutoresizingMaskIntoConstraints = false // Needed for autolayout
        self.dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        self.dimmingView.alpha = 0.0
        
        // Add tap for dimming view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.dimmingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        self.presentingViewController.dismiss(animated: true)
    }
}
