//
//  SwiftBarrageVerticalText.swift
//  SwiftBarrage
//
//  Created by Isaac on 2018/6/1.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit
public class SwiftBarrageVerticalTextDescriptor: SwiftBarrageTextDescriptor {
    
}
public class SwiftBarrageVerticalTextCell: SwiftBarrageTextCell {
    var verticalTextDescriptor: SwiftBarrageTextDescriptor?
    override func addBarrageAnimation(with animationDelegate: CAAnimationDelegate) {
        if let superview = self.superview,
            let descriptor = self.barrageDescriptor {
            let startCenter = CGPoint(x: superview.bounds.minX+80, y: superview.bounds.height+bounds.height/2)
            let endCenter = CGPoint(x: superview.bounds.minX+80, y: bounds.height/2)
            let walkAnimation = CAKeyframeAnimation(keyPath: "position")
            walkAnimation.values = [NSValue(cgPoint: startCenter),NSValue(cgPoint: endCenter)]
            walkAnimation.keyTimes = [0,1]
            walkAnimation.duration = descriptor.animationDuration
            walkAnimation.repeatCount = 1
            walkAnimation.delegate = animationDelegate
            walkAnimation.isRemovedOnCompletion = false
            walkAnimation.fillMode = .forwards
            self.layer.add(walkAnimation, forKey: kBarrageAnimation)
        }
    }
    override func set(barrageDescriptor: SwiftBarrageDescriptor) {
        super.set(barrageDescriptor: barrageDescriptor)
        if let descriptor = barrageDescriptor as? SwiftBarrageVerticalTextDescriptor {
            self.verticalTextDescriptor = descriptor
        }
    }
}
