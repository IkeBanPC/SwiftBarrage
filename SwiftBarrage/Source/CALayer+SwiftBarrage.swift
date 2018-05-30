//
//  CALayer+SwiftBarrage.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit
extension CALayer {
    func convertContentToImageWithSize(contentSize: CGSize?) -> UIImage? {
        guard let contentSize = contentSize else {return nil}
        UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            self.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}
