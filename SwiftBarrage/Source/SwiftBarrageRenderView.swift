//
//  SwiftBarrageRenderView.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit

public enum SwiftBarrageRenderStatus: Int {
    case stopped = 0
    case started
    case paused
}

public class SwiftBarrageRenderView: UIView {
    
    var animationCells = [SwiftBarrageCell]()
    var idleCells = [SwiftBarrageCell]()
    var lastestCell: SwiftBarrageCell?
    
    var animatingCellsLock: DispatchSemaphore
    var idleCellsLock: DispatchSemaphore
    var trackInfoLock: DispatchSemaphore
    var lowPositionView: UIView
    var middlePositionView: UIView
    var highPositionView: UIView
    var veryHighPositionView: UIView
    
    var autoClear: Bool?
    var renderStatus: SwiftBarrageRenderStatus
    var trackNextAvailableTime: [String:String]
    var renderPositionStyle:SwiftBarrageRenderPositionStyle?
    
    init() {
        animatingCellsLock = DispatchSemaphore(value: 1)
        idleCellsLock = DispatchSemaphore(value: 1)
        trackInfoLock = DispatchSemaphore(value: 1)
        lowPositionView = UIView()
        middlePositionView = UIView()
        highPositionView = UIView()
        veryHighPositionView = UIView()
        trackNextAvailableTime = [String:String]()
        renderStatus = .stopped
        super.init(frame: CGRect())
        addSubview(lowPositionView)
        addSubview(middlePositionView)
        addSubview(highPositionView)
        addSubview(veryHighPositionView)
        layer.masksToBounds = true
    }
    required public init?(coder aDecoder: NSCoder) {
        animatingCellsLock = DispatchSemaphore(value: 1)
        idleCellsLock = DispatchSemaphore(value: 1)
        trackInfoLock = DispatchSemaphore(value: 1)
        lowPositionView = UIView()
        middlePositionView = UIView()
        highPositionView = UIView()
        veryHighPositionView = UIView()
        trackNextAvailableTime = [String:String]()
        renderStatus = .stopped
        super.init(coder: aDecoder)
        addSubview(lowPositionView)
        addSubview(middlePositionView)
        addSubview(highPositionView)
        addSubview(veryHighPositionView)
        layer.masksToBounds = true
    }
    public func dequeueReusableCell(with barrageCellClass: AnyClass?) -> SwiftBarrageCell? {
        var barrageCell: SwiftBarrageCell? = nil
    
        _ = idleCellsLock.wait(timeout: DispatchTime.distantFuture)
        for cell in idleCells {
            if cell.classForCoder == barrageCellClass {
                barrageCell = cell
                break
            }
        }
        if let cell = barrageCell {
            if let index = idleCells.index(of: cell) {
                self.idleCells.remove(at: index)
                cell.idleTime = 0.0
            }
        } else {
            barrageCell = newCell(with: barrageCellClass)
        }
        idleCellsLock.signal()
        return barrageCell
    }
    public func start() {
        switch renderStatus                                                                                                                                                     {
        case .started:
            return
        case .paused:
            self.resume()
        default:
            renderStatus = .started
        }
    }
    public func pause() {
        switch renderStatus {
        case .started:
            renderStatus = .paused
        default:
            return
        }
        _ = animatingCellsLock.wait(timeout: DispatchTime.distantFuture)
        for cell in animationCells.reversed() {
            let pausedTime = cell.layer.convertTime(CACurrentMediaTime(), from: nil)
            cell.layer.speed = 0
            cell.layer.timeOffset = pausedTime
        }
        animatingCellsLock.signal()
    }
    public func resume() {
        switch renderStatus {
        case .paused:
            renderStatus = .started
        default:
            return
        }
        _ = animatingCellsLock.wait(timeout: DispatchTime.distantFuture)
        for cell in animationCells.reversed() {
            let pausedTime = cell.layer.timeOffset
            cell.layer.speed = 1
            cell.layer.timeOffset = 0
            cell.layer.beginTime = 0
            let timeSincePause = cell.layer.convertTime(CACurrentMediaTime(), from: nil)-pausedTime
            cell.layer.beginTime = timeSincePause
        }
        animatingCellsLock.signal()
    }
    public func stop() {
        switch renderStatus {
        case .started:
            renderStatus = .stopped
        case .paused:
            renderStatus = .stopped
        default:
            return
        }
        if autoClear == true {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(clearIdleCells), object: nil)
        }
        _ = animatingCellsLock.wait(timeout: DispatchTime.distantFuture)
        for cell in animationCells.reversed() {
            let pausedTime = cell.layer.convertTime(CACurrentMediaTime(), from: nil)
            cell.layer.speed = 0
            cell.layer.timeOffset = pausedTime
            cell.layer.removeAllAnimations()
            cell.removeFromSuperview()
        }
        animationCells.removeAll()
        animatingCellsLock.signal()
        _ = idleCellsLock.wait(timeout: DispatchTime.distantFuture)
        idleCells.removeAll()
        idleCellsLock.signal()
        _ = trackInfoLock.wait(timeout: DispatchTime.distantFuture)
        trackNextAvailableTime.removeAll()
        trackInfoLock.signal()
    }
    public func newCell(with barrageCellClass: AnyClass?) -> SwiftBarrageCell? {
        if let barrageCell = (barrageCellClass as? SwiftBarrageCell.Type)?.init() {
            return barrageCell
        }
        return nil
    }
    public func fire(barrageCell: SwiftBarrageCell) {
        switch renderStatus {
        case .started:
            break
        default:
            return
        }
        barrageCell.clearContents()
        barrageCell.updateSubviewsData()
        barrageCell.layoutContentSubviews()
        barrageCell.convertContentToImage()
        barrageCell.sizeToFit()
        barrageCell.removeSubViewsAndSublayers()
        barrageCell.addBorderAttributes()
        _ = animatingCellsLock.wait(timeout: DispatchTime.distantFuture)
        lastestCell = animationCells.last
        animationCells.append(barrageCell)
        barrageCell.idle = false
        animatingCellsLock.signal()
        add(barrageCell: barrageCell, with: barrageCell.barrageDescriptor?.positionPriority)
        let cellFrame = calculationFrame(of: barrageCell)
        barrageCell.frame = cellFrame
        barrageCell.addBarrageAnimation(with: self)
        recordTrackInfo(with: barrageCell)
        lastestCell = barrageCell
    }
    
    func add(barrageCell: SwiftBarrageCell, with positionPriority: SwiftBarragePositionPriority?) {
        switch positionPriority ?? .middle {
        case .middle:
            self.insertSubview(barrageCell, aboveSubview: middlePositionView)
        case .high:
            self.insertSubview(barrageCell, aboveSubview: highPositionView)
        case .veryHigh:
            self.insertSubview(barrageCell, aboveSubview: veryHighPositionView)
        case .low:
            self.insertSubview(barrageCell, aboveSubview: lowPositionView)
        }
    }
    
    func calculationFrame(of barrageCell: SwiftBarrageCell) -> CGRect {
        var cellFrame = barrageCell.bounds
        cellFrame.origin.x = self.frame.maxX
        if barrageCell.barrageDescriptor?.renderRange?.lowerBound == 0 &&  barrageCell.barrageDescriptor?.renderRange?.upperBound == 0 {
            let cellHeight = barrageCell.bounds.height
            let minOriginY = barrageCell.barrageDescriptor?.renderRange?.lowerBound
            let maxOriginY = barrageCell.barrageDescriptor?.renderRange?.upperBound
            if minOriginY
            
        }
        return CGRect()
    }
    
    func recordTrackInfo(with barrageCell: SwiftBarrageCell) {
        
    }
    
    @objc public func clearIdleCells() {
        
    }
}

extension SwiftBarrageRenderView: CAAnimationDelegate {
    
}
