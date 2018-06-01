//
//  SwiftBarrageGifCell.swift
//  SwiftBarrage
//
//  Created by Isaac on 2018/6/1.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//


import UIKit
public class SwiftBarrageGifDescriptor: SwiftBarrageDescriptor {
    var image: YYImage?
    override init() {
        super.init()
        shouldRemoveSubViewsAndSublayers = false
    }
}

public class SwiftBarrageGifCell: SwiftBarrageCell {
    var gifDescriptor: SwiftBarrageGifDescriptor?
    var gifView: YYAnimatedImageView
    public required init() {
        gifView = YYAnimatedImageView()
        gifView.autoPlayAnimatedImage = true
        super.init()
        addSubview(gifView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        gifView = YYAnimatedImageView()
        gifView.autoPlayAnimatedImage = true
        super.init(coder: aDecoder)
        addSubview(gifView)
        
    }
    override func updateSubviewsData() {
        self.gifView.image = gifDescriptor?.image
    }
    override func layoutContentSubviews() {
        gifView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }
    
    override func addBarrageAnimation(with animationDelegate: CAAnimationDelegate) {
        if let superview = self.superview,
            let descriptor = self.barrageDescriptor {
            let startCenter = CGPoint(x: superview.bounds.maxX+bounds.width/2, y: center.y)
            let endCenter = CGPoint(x: -bounds.width/2, y: center.y)
            let walkAnimation = CAKeyframeAnimation(keyPath: "position")
            walkAnimation.values = [NSValue(cgPoint: startCenter),NSValue(cgPoint: endCenter)]
            walkAnimation.keyTimes = [0,1]
            walkAnimation.duration = descriptor.animationDuration
            walkAnimation.repeatCount = 1
            walkAnimation.delegate = animationDelegate
            walkAnimation.isRemovedOnCompletion = false
            walkAnimation.fillMode = kCAFillModeForwards
            layer.add(walkAnimation, forKey: kBarrageAnimation)
        }
    }
    override func set(barrageDescriptor: SwiftBarrageDescriptor) {
        super.set(barrageDescriptor: barrageDescriptor)
        if let gifDescriptor = barrageDescriptor as? SwiftBarrageGifDescriptor {
            self.gifDescriptor = gifDescriptor
        }
    }
}
