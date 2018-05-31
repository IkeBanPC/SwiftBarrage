//
//  SwiftBarrageManager.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit

public class SwiftBarrageManager {
    public var renderView: SwiftBarrageRenderView
    var renderStatus: SwiftBarrageRenderStatus?
    init() {
        renderView = SwiftBarrageRenderView()
    }
    
    public func start() {
        self.renderView.start()
    }
    
    public func stop() {
        self.renderView.stop()
    }
    
    public func pause() {
        self.renderView.pause()
    }
    
    public func resume() {
        self.renderView.resume()
    }
    
    public func render(barrageDescriptor: SwiftBarrageDescriptor) {
        if let barrageCell = self.renderView.dequeueReusableCell(with: barrageDescriptor.barrageCellClass) {
            barrageCell.set(barrageDescriptor: barrageDescriptor)
            self.renderView.fire(barrageCell: barrageCell)
        }
    }
}
