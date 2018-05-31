//
//  SwiftBarrageHeader.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import Foundation
public let kBarrageAnimation = "kBarrageAnimation"
public enum SwiftBarragePositionPriority: Int {
    case low = 0
    case middle
    case high
    case veryHigh
}
public enum SwiftBarrageRenderPositionStyle: Int {
    case randomTracks = 0
    case random
    case increase
}
public typealias SwiftBarrageTouchAction = (SwiftBarrageDescriptor) -> ()
