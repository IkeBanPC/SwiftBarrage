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
    var trackNextAvailableTime: [String:SwiftBarrageTrackInfo]
    var renderPositionStyle:SwiftBarrageRenderPositionStyle
    
    init() {
        animatingCellsLock = DispatchSemaphore(value: 1)
        idleCellsLock = DispatchSemaphore(value: 2)
        trackInfoLock = DispatchSemaphore(value: 3)
        lowPositionView = UIView()
        middlePositionView = UIView()
        highPositionView = UIView()
        veryHighPositionView = UIView()
        trackNextAvailableTime = [String:SwiftBarrageTrackInfo]()
        renderStatus = .stopped
        renderPositionStyle = .randomTracks
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
        trackNextAvailableTime = [String:SwiftBarrageTrackInfo]()
        renderStatus = .stopped
        renderPositionStyle = .randomTracks
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
        let cellFrame = calculationFrame(barrageCell: barrageCell)
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
    
    func calculationFrame(barrageCell: SwiftBarrageCell) -> CGRect {
        var cellFrame = barrageCell.bounds
        cellFrame.origin.x = self.frame.maxX
        if barrageCell.barrageDescriptor?.renderRange == Range<CGFloat>.init(uncheckedBounds: (0,0)) {
            let cellHeight = barrageCell.bounds.height
            if var minOriginY = barrageCell.barrageDescriptor?.renderRange?.lowerBound,
                var maxOriginY = barrageCell.barrageDescriptor?.renderRange?.upperBound {
                if maxOriginY > self.bounds.height {
                    maxOriginY = self.bounds.height
                }
                if minOriginY < 0 {
                    minOriginY = 0
                }
                var renderHeight = maxOriginY-minOriginY
                if renderHeight < 0 {
                    renderHeight = cellHeight
                }
                let trackCount = Int(floorf(Float(renderHeight/cellHeight)))
                var trackIndex = Int(arc4random_uniform(UInt32(trackCount)))
                _ = trackInfoLock.wait(timeout: DispatchTime.distantFuture)
                let trackInfo = trackNextAvailableTime[kNextAvailableTimeKey(identifier: NSStringFromClass(barrageCell.classForCoder), index: trackIndex)]
                if let time = trackInfo?.nextAvailableTime {
                    if time > CACurrentMediaTime() {
                        var availableTrackInfos = [SwiftBarrageTrackInfo]()
                        for info in trackNextAvailableTime.values {
                            if CACurrentMediaTime() > info.nextAvailableTime && info.trackIdentifier.contains(NSStringFromClass(barrageCell.classForCoder)) {
                                availableTrackInfos.append(info)
                            }
                        }
                        if let randomInfo = availableTrackInfos.randomObject() {
                            trackIndex = randomInfo.trackIndex
                        } else {
                            if trackNextAvailableTime.count < trackCount {
                                var numberArray = [Int]()
                                for index in 0 ..< trackCount {
                                    if let _ = trackNextAvailableTime[kNextAvailableTimeKey(identifier: NSStringFromClass(barrageCell.classForCoder), index: index)] {
                                        numberArray.append(index)
                                    }
                                }
                                if let value = numberArray.randomObject() {
                                    trackIndex = value
                                }
                            }
                        }
                    }
                }
                _ = trackInfoLock.signal()
                barrageCell.trackIndex = trackIndex
                cellFrame.origin.y = CGFloat(trackIndex)*cellHeight+minOriginY
            }
        } else {
            switch renderPositionStyle {
            case .random :
                let maxY = self.bounds.height - cellFrame.height
                let originY = Int(floorf(Float(maxY)))
                cellFrame.origin.y = CGFloat(arc4random_uniform(UInt32(originY)))
            case .increase:
                if let cell = lastestCell {
                    let lastestFrame = cell.frame
                    cellFrame.origin.y = lastestFrame.maxY
                } else {
                    cellFrame.origin.y = 0
                }
            case .randomTracks:
                let renderViewHeight = self.bounds.height
                let cellHeight = barrageCell.bounds.height
                let floatCount = floorf(Float(renderViewHeight/cellHeight))
                
                
                guard !(floatCount.isNaN || floatCount.isInfinite) else {
                    
                    return CGRect()
                }
                
                let trackCount = Int(floatCount)
                var trackIndex = Int(arc4random_uniform(UInt32(trackCount)))
                _ = trackInfoLock.wait(timeout: DispatchTime.distantFuture)
                let trackInfo = trackNextAvailableTime[kNextAvailableTimeKey(identifier: NSStringFromClass(barrageCell.classForCoder), index: trackIndex)]
                if let time = trackInfo?.nextAvailableTime {
                    if time > CACurrentMediaTime() {
                        var availableTrackInfos = [SwiftBarrageTrackInfo]()
                        for info in trackNextAvailableTime.values {
                            if CACurrentMediaTime() > info.nextAvailableTime && info.trackIdentifier.contains(NSStringFromClass(barrageCell.classForCoder)) {
                                availableTrackInfos.append(info)
                            }
                        }
                        if let randomInfo = availableTrackInfos.randomObject() {
                            trackIndex = randomInfo.trackIndex
                        } else {
                            if trackNextAvailableTime.count < trackCount {
                                var numberArray = [Int]()
                                for index in 0 ..< trackCount {
                                    if let _ = trackNextAvailableTime[kNextAvailableTimeKey(identifier: NSStringFromClass(barrageCell.classForCoder), index: index)] {
                                        numberArray.append(index)
                                    }
                                }
                                if let value = numberArray.randomObject() {
                                    trackIndex = value
                                }
                            }
                        }
                    }
                }
                _ = trackInfoLock.signal()
                barrageCell.trackIndex = trackIndex
                cellFrame.origin.y = CGFloat(trackIndex)*cellHeight
            }
        }
        if cellFrame.maxY > self.bounds.height {
            cellFrame.origin.y = 0
        } else if cellFrame.origin.y < 0{
            cellFrame.origin.y = 0
        }
        return cellFrame
    }
    
    @objc public func clearIdleCells() {
        _ = idleCellsLock.wait(timeout: DispatchTime.distantFuture)
        let timeInterval = Date().timeIntervalSince1970
        for (index,cell) in idleCells.enumerated() {
            let time = timeInterval - cell.idleTime
            if time > 5 && cell.idleTime > 0 {
                idleCells.remove(at: index)
                break
            }
        }
        if (self.idleCells.isEmpty) {
            autoClear = false
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5.0) {
                self.clearIdleCells()
            }
        }
        _ = idleCellsLock.signal()
    }
    
    func recordTrackInfo(with barrageCell: SwiftBarrageCell) {
        let key = kNextAvailableTimeKey(identifier: NSStringFromClass(barrageCell.classForCoder), index: barrageCell.trackIndex)
        guard let animation = barrageCell.barrageAnimation else {return}
        
        let duration = animation.duration
        var fromValue: NSValue?
        var toValue: NSValue?
        if let basicAnimation = animation as? CABasicAnimation {
            fromValue = basicAnimation.fromValue as? NSValue
            toValue = basicAnimation.toValue as? NSValue
        }
        if let keyframeAnimation = animation as? CAKeyframeAnimation {
            fromValue = keyframeAnimation.values?.first as? NSValue
            toValue = keyframeAnimation.values?.last as? NSValue
        }
        if let fromValueType = fromValue?.objCType ,
            let toValueType = toValue?.objCType{
            if let fromValueTypeString = String(validatingUTF8: fromValueType),
                let toValueTypeString = String(validatingUTF8: toValueType) {
                if fromValueTypeString != toValueTypeString {
                    return
                }
                if fromValueTypeString.contains("CGPoint") {
                    if let fromPoint = fromValue?.cgPointValue,
                        let toPoint = toValue?.cgPointValue{
                        _ = trackInfoLock.wait(timeout: DispatchTime.distantFuture)
                        var trackInfo = trackNextAvailableTime[key]
                        if trackInfo == nil {
                            trackInfo = SwiftBarrageTrackInfo.init(trackIndex: barrageCell.trackIndex, trackIdentifier: key)
                        }
                        trackInfo!.barrageCount += 1
                        trackInfo!.nextAvailableTime = CFTimeInterval(barrageCell.bounds.width)
                        let distanceX = fabs(toPoint.x-fromPoint.x)
                        let distanceY = fabs(toPoint.y-fromPoint.y)
                        let distance = max(distanceX, distanceY)
                        let speed = Double(distance)/duration
                        if(distanceX == distance) {
                            let time = Double(barrageCell.bounds.width)/speed
                            trackInfo!.nextAvailableTime = CACurrentMediaTime() + time + 0.1
                            trackNextAvailableTime[key] = trackInfo!
                        }
                        _ = trackInfoLock.signal()
                        return
                    }
                } else if fromValueTypeString.contains("CGVector") {
                    return
                }
            }
        }
    }
    
    
}

func kNextAvailableTimeKey(identifier:String,index:Int) -> String{
    return "\(identifier)_\(index)"
}
extension SwiftBarrageRenderView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag {return}
        if self.renderStatus == .stopped {return}
        _ = animatingCellsLock.wait(timeout: .distantFuture)
        var animationedCell: SwiftBarrageCell?
        for cell in animationCells {
            if let animation = cell.barrageAnimation {
                if animation == anim {
                    animationedCell = cell
                    if let index = animationCells.index(of: cell) {
                        animationCells.remove(at: index)
                        break
                    }
                }
            }
        }
        _ = animatingCellsLock.signal()
        if animationedCell == nil {
            return
        }
        _ = trackInfoLock.wait(timeout: .distantFuture)
        if let trackInfo = trackNextAvailableTime[kNextAvailableTimeKey(identifier: NSStringFromClass(animationedCell!.classForCoder), index: animationedCell!.trackIndex)] {
            trackInfo.barrageCount -= 1
        }
        _ = trackInfoLock.signal()
        animationedCell!.removeFromSuperview()
        animationedCell!.prepareForReuse()
        _ = idleCellsLock.wait(timeout: .distantFuture)
        animationedCell!.idleTime = Date().timeIntervalSince1970;
        idleCells.append(animationedCell!)
        _ = idleCellsLock.signal()
        if (autoClear == false || autoClear == nil) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                self.clearIdleCells()
            }
            autoClear = true
        }
    }
}

extension SwiftBarrageRenderView {
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if event?.type == UIEventType.touches {
            if let touch = touches.first {
                let point = touch.location(in: self)
                _ = animatingCellsLock.wait(timeout: .distantFuture)
                for cell in animationCells {
                    if let presentationLayer = cell.layer.presentation() {
                        if presentationLayer.hitTest(point) != nil {
                            if cell.barrageDescriptor?.touchAction != nil,
                                let barrageDescriptor = cell.barrageDescriptor{
                                barrageDescriptor.touchAction?(barrageDescriptor)
                            }
                            break
                        }
                    }
                }
                _ = animatingCellsLock.signal()
            }
        }
    }
}
