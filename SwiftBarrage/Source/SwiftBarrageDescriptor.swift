//
//  SwiftBarrageDescriptor.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit

public class SwiftBarrageDescriptor {
    var barrageCellClass: AnyClass?
    var positionPriority: SwiftBarragePositionPriority?
    var animationDuration: CFTimeInterval?
    var touchAction: SwiftBarrageTouchAction?
    var borderColor: UIColor?
    var borderWidth: CGFloat?
    var cornerRadius: CGFloat?
    var renderRange: Range<CGFloat>?
    init() {
    }
}
