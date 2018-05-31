//
//  SwiftBarrageCell.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit
public class SwiftBarrageCell: UIView {
    var idle: Bool?
    var idleTime: TimeInterval = 0
    var barrageDescriptor: SwiftBarrageDescriptor?
    var trackIndex: Int
    
    public var barrageAnimation: CAAnimation? {
        get {
            return self.layer.animation(forKey: kBarrageAnimation)
        }
    }
    required public init() {
        self.trackIndex = -1
        super.init(frame: CGRect())
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.trackIndex = -1
        super.init(coder: aDecoder)
        
    }
    
    func prepareForReuse() {
        self.layer.removeAnimation(forKey: kBarrageAnimation)
        barrageDescriptor = nil
        if idle == false || idle == nil {
            idle = true
        }
        trackIndex = -1
    }
    
    func set(barrageDescriptor: SwiftBarrageDescriptor) {
        self.barrageDescriptor = barrageDescriptor
    }
    
    func clearContents() {
        self.layer.contents = nil
    }
    
    func convertContentToImage() {}
    
    public override func sizeToFit() {
        var height: CGFloat = 0
        var width: CGFloat = 0
        if let sublayers = self.layer.sublayers {
            for sublayer in sublayers {
                let maxY = sublayer.frame.maxY
                if maxY > height {
                    height = maxY
                }
                let maxX = sublayer.frame.maxX
                if maxX > width {
                    width = maxX
                }
            }
        }
        if width == 0 || height == 0 {
            if let content = self.layer.contents as! CGImage? {
                let image = UIImage(cgImage: content)
                width = image.size.width/UIScreen.main.scale
                height = image.size.height/UIScreen.main.scale
            }
        }
        self.bounds = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    func removeSubViewsAndSublayers() {
        for view in self.subviews.reversed() {
            view.removeFromSuperview()
        }
        if let sublayers = self.layer.sublayers?.reversed() {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func addBorderAttributes() {
        if let borderColor = self.barrageDescriptor?.borderColor?.cgColor {
            self.layer.borderColor = borderColor
        }
        if let borderWidth = self.barrageDescriptor?.borderWidth {
            self.layer.borderWidth = borderWidth
        }
        if let cornerRadius = self.barrageDescriptor?.cornerRadius {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    func addBarrageAnimation(with animationDelegate: CAAnimationDelegate) {}
    
    func updateSubviewsData() {}
    
    func layoutContentSubviews() {}
    
    
    
}
