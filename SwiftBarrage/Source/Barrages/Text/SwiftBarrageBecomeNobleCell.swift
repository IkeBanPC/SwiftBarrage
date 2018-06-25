//
//  SwiftBarrageBecomeNobleCell.swift
//  SwiftBarrage
//
//  Created by Isaac on 2018/6/1.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import Foundation
public class SwiftBarrageBecomeNobleDescriptor: SwiftBarrageTextDescriptor {
    var backgroundImage: UIImage?
}
public class SwiftBarrageBecomeNobleCell: SwiftBarrageTextCell{
    var nobleDescriptor: SwiftBarrageBecomeNobleDescriptor?
    var backgroundImageLayer: CALayer
    
    required public init() {
        backgroundImageLayer = CALayer()
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        backgroundImageLayer = CALayer()
        super.init(coder: aDecoder)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.insertSublayer(backgroundImageLayer, at: 0)
    }
    override func updateSubviewsData() {
        super.updateSubviewsData()
        backgroundImageLayer.contents = nobleDescriptor?.backgroundImage?.cgImage
    }
    override func layoutContentSubviews() {
        super.layoutContentSubviews()
        if let image = nobleDescriptor?.backgroundImage {
            backgroundImageLayer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        }
        var center = backgroundImageLayer.position
        center.y += 17.0
        self.textLabel.center = center
    }
    override func convertContentToImage() {
        if let image = nobleDescriptor?.backgroundImage {
            let layerImage = self.layer.convertContentToImageWithSize(contentSize: CGSize(width: image.size.width, height: image.size.height))
            layer.contents = layerImage?.cgImage
        }
    }
    override func addBarrageAnimation(with animationDelegate: CAAnimationDelegate) {
        if let superview = self.superview {
            let startCenter = CGPoint(x: superview.bounds.maxX+bounds.width/2, y: center.y)
            let stopCenter = CGPoint(x: superview.bounds.midX, y: center.y)
            let endCenter = CGPoint(x: -bounds.width/2, y: center.y)
            let walkAnimation = CAKeyframeAnimation(keyPath: "position")
            walkAnimation.values = [NSValue(cgPoint: startCenter),NSValue(cgPoint: stopCenter),NSValue(cgPoint: stopCenter),NSValue(cgPoint: endCenter)]
            walkAnimation.keyTimes = [0.0,0.25,0.75,1.0]
            if let duration = self.textDescriptor?.animationDuration {
                walkAnimation.duration = duration
            }
            walkAnimation.repeatCount = 1
            walkAnimation.delegate = animationDelegate
            walkAnimation.isRemovedOnCompletion = false
            walkAnimation.fillMode = .forwards
            self.layer.add(walkAnimation, forKey: kBarrageAnimation)
        }
    }
    override func set(barrageDescriptor: SwiftBarrageDescriptor) {
        super.set(barrageDescriptor: barrageDescriptor)
        if let descriptor = barrageDescriptor as? SwiftBarrageBecomeNobleDescriptor {
            self.nobleDescriptor = descriptor
        }
    }
}


