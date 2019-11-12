//
//  OverlaySegue.swift
//  AllIWantFor
//
//  Created by Michael Nino Evensen on 13/09/2017.
//  Copyright © 2017 Michael Evensen. All rights reserved.
//

import Foundation
import UIKit

class OverlaySegue: UIStoryboardSegue {
    let transitioningDelegate = OverlayTransitioningDelegate()
    
    override func perform() {
        destination.modalPresentationStyle = .custom
        destination.transitioningDelegate = transitioningDelegate
        
        super.perform()
    }
}

class OverlayTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return OverlayPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
