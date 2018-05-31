//
//  Extensions.swift
//  SwiftBarrage
//
//  Created by Isaac on 2018/5/31.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import Foundation
extension Array {
    public func randomObject() -> Element? {
        let count = self.count
        if count > 0 {
            let randomIndex = arc4random_uniform(UInt32(count))
            let index = Int(randomIndex)
            return self[index]
        }
        return nil
    }
}
