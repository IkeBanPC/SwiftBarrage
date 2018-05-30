//
//  SwiftBarrageTextCell.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit

public class SwiftBarrageTextCell: SwiftBarrageCell {
    var textLabel: UILabel? {
        get {
            if self.textLabel == nil {
                self.textLabel = UILabel()
                self.textLabel?.textAlignment = .center
            }
            return self.textLabel
        }
        set {
            self.textLabel = newValue
        }
    }
    var textDescriptor: SwiftBarrageTextDescriptor?
    required public init() {
        super.init()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func updateSubviewsData() {
        if let label = textLabel {
            addSubview(label)
        }
        if textDescriptor?.textShadowOpened == true {
            if let textDescriptor = self.textDescriptor {
                textLabel?.layer.shadowColor = textDescriptor.shadowColor.cgColor
                textLabel?.layer.shadowOpacity = textDescriptor.shadowOpacity
                textLabel?.layer.shadowOffset = textDescriptor.shadowOffset
                textLabel?.layer.shadowRadius = textDescriptor.shadowRadius
            }
        }
        textLabel?.attributedText = textDescriptor?.attributedText
    }
    
    override func layoutContentSubviews() {
        if let textDescriptor = self.textDescriptor {
            if let text = textDescriptor.attributedText?.string as NSString? {
                let frame = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: textDescriptor.attributedText?.attributes(at: 0, effectiveRange: nil), context: nil)
                self.textLabel?.frame = frame
            }
        }
    }
    
    override func convertContentToImage() {
        let contentImage = self.layer.convertContentToImageWithSize(contentSize: textLabel?.frame.size)
        self.layer.contents = contentImage?.cgImage
    }
    
    override func removeSubViewsAndSublayers() {
        super.removeSubViewsAndSublayers()
        textLabel = nil
    }
    override func addBarrageAnimation(with animationDelegate: CAAnimationDelegate) {
        guard let superview = self.superview else {return}
        let startCenter = CGPoint(x: superview.bounds.maxX+self.bounds.width/2, y: self.center.y)
        let endCenter = CGPoint(x: -self.bounds.width/2, y: self.center.y)
        let walkAnimation = CAKeyframeAnimation(keyPath: "position")
        walkAnimation.values = [NSValue(cgPoint: startCenter),NSValue(cgPoint: endCenter)]
        walkAnimation.keyTimes = [0.0,1.0]
        if let duration = self.textDescriptor?.animationDuration {
            walkAnimation.duration = duration
        }
        walkAnimation.repeatCount = 1
        walkAnimation.delegate = animationDelegate
        walkAnimation.isRemovedOnCompletion = false
        walkAnimation.fillMode = kCAFillModeForwards
        self.layer.add(walkAnimation, forKey: kBarrageAnimation)
    }
    
    override func set(barrageDescriptor: SwiftBarrageDescriptor) {
        super.set(barrageDescriptor: barrageDescriptor)
        if case let barrageDescriptor as SwiftBarrageTextDescriptor = barrageDescriptor {
            self.textDescriptor = barrageDescriptor
        }
    }
}
