//
//  SlideInPresentationManager.swift
//  PresentationController
//
//  Created by Michael Nino Evensen on 12/11/2019.
//  Copyright © 2019 Michael Nino Evensen. All rights reserved.
//

import Foundation
import UIKit


class SlideInSegue: UIStoryboardSegue {

    private var segue: SlideInSegue? = nil

    // Default direction
    var direction: PresentationDirection = .bottom

    override func perform() {
        
        // Reference to self is weak, so retain it.
        self.segue = self
        
        destination.modalPresentationStyle = .custom
        destination.transitioningDelegate = self

        source.present(destination, animated: true, completion: nil)
    }
}

public enum PresentationDirection {
    case left
    case top
    case right
    case bottom
}

// MARK: - Transitioning Delegate
extension SlideInSegue: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    
        return SlideInPresentationController(presentedViewController: presented,
                                             presenting: presenting,
                                             direction: self.direction)
    }
    
    // Open
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: self.direction, isPresentation: true)
    }
    
    // Dismiss
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.segue = nil
        return SlideInPresentationAnimator(direction: self.direction, isPresentation: false)
    }
}

