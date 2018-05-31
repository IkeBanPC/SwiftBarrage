//
//  SwiftBarrageTrackInfo.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit

public class SwiftBarrageTrackInfo {
    var trackIndex: Int
    var trackIdentifier: String
    var nextAvailableTime: CFTimeInterval = 0
    var barrageCount: Int = 0
    var trackHeight: CGFloat?
    init(trackIndex:Int,trackIdentifier:String) {
        self.trackIndex = trackIndex
        self.trackIdentifier = trackIdentifier
    }
}
