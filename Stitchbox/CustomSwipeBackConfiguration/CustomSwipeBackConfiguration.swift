//
//  CustomSwipeBackConfiguration.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 6/1/23.
//

import Foundation
import SwipeTransition
import SwipeTransitionAutoSwipeBack
import SwipeTransitionAutoSwipeToDismiss

class CustomSwipeBackConfiguration: SwipeBackConfiguration {
    override var transitionDuration: TimeInterval {
        get { return 1.5 }
        set { super.transitionDuration = newValue }
    }
    
    override var parallaxFactor: CGFloat {
        get { return 0.5 }
        set { super.parallaxFactor = newValue }
    }
    
}
