//
//  SwiftBarrageDescriptor.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit

public class SwiftBarrageDescriptor {
    var shouldRemoveSubViewsAndSublayers: Bool = true
    var barrageCellClass: AnyClass?
    var positionPriority: SwiftBarragePositionPriority?
    var animationDuration: CFTimeInterval = 1
    var touchAction: SwiftBarrageTouchAction?
    var borderColor: UIColor?
    var borderWidth: CGFloat?
    var cornerRadius: CGFloat?
    var renderRange: Range<CGFloat>?
    init() {
    }
}
