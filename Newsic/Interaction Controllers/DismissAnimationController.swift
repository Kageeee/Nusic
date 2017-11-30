//
//  PresentAnimationController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 30/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let destinationFrame: CGRect
    let interactionController: SwipeInteractionController?
    
    init(destinationFrame: CGRect, interactionController: SwipeInteractionController?) {
        self.destinationFrame = destinationFrame
        self.interactionController = interactionController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        // 1
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        let bounds = UIScreen.main.bounds
        let rectOffset = CGRect(origin: finalFrameForVC.origin, size: finalFrameForVC.size)
        let snapshotView = toViewController.view.snapshotView(afterScreenUpdates: false)
        
        
        snapshotView?.frame = rectOffset.offsetBy(dx: -bounds.size.width, dy: 0)
        containerView.addSubview(snapshotView!)
        
        let snapshotFromView = fromViewController.view.snapshotView(afterScreenUpdates: false)
        //containerView.addSubview(snapshotFromView!)
        containerView.insertSubview(snapshotFromView!, belowSubview: snapshotView!)
        
        fromViewController.view.alpha = 0
        toViewController.view.alpha = 0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            snapshotView?.frame = finalFrameForVC
            snapshotFromView?.frame = fromViewController.view.frame.insetBy(dx: fromViewController.view.frame.width / 20, dy: fromViewController.view.frame.height / 20)
            snapshotFromView?.alpha = 0.5
        }, completion: {
            finished in
            snapshotView?.removeFromSuperview()
            snapshotFromView?.removeFromSuperview()
            let wasCancelled = transitionContext.transitionWasCancelled
            fromViewController.view.alpha = 1
            toViewController.view.alpha = 1
            transitionContext.completeTransition(!wasCancelled)
        })
        
    }
    
}

