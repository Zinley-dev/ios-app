//
//  SlideAnimator.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/28/23.
//

import Foundation
import UIKit

class SlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting = false

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            return
        }

        let direction: CGFloat = isPresenting ? -1 : 1
        let fromViewEndFrame = fromView.frame.offsetBy(dx: direction * containerView.frame.width, dy: 0)
        let toViewStartFrame = toView.frame.offsetBy(dx: -direction * containerView.frame.width, dy: 0)

        if isPresenting {
            toView.frame = toViewStartFrame
            containerView.addSubview(toView)
        }

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, animations: {
            if self.isPresenting {
                toView.frame = fromView.frame
            } else {
                fromView.frame = fromViewEndFrame
            }
        }, completion: { finished in
            if !self.isPresenting, !transitionContext.transitionWasCancelled {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

