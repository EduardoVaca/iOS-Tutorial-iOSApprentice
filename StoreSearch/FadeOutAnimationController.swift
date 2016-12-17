//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by Eduardo Vaca on 17/12/16.
//  Copyright © 2016 Vaca. All rights reserved.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: .from) {
            let duration = transitionDuration(using: transitionContext)
            UIView.animate(withDuration: duration, animations: { 
                    fromView.alpha = 0
                }, completion: { (finished) in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}
