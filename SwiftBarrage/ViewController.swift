//
//  ViewController.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var manager: SwiftBarrageManager!
    var statusFlag = false
    var stopY: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = SwiftBarrageManager()
        self.view.addSubview(manager.renderView)
        manager.renderView.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height-64-80)
        manager.renderView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        view.backgroundColor = .black
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func addBarrage() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.addText()
            self.addVerticalText()
            self.addGif()
            self.addMixedTextAndImage()
            self.addNoble()
        }
    }
    func addText() {
        let count = manager.renderView.animationCells.count
        self.title = "现在有\(count)条弹幕"
        let textDescriptor = SwiftBarrageTextDescriptor()
        textDescriptor.text = "SwiftBarrage"
        textDescriptor.textColor = .white
        textDescriptor.borderColor = .white
        textDescriptor.borderWidth = 1
        textDescriptor.verticalSpace = 5
        textDescriptor.horizontalSpace = 5
        textDescriptor.cornerRadius = UIFont.systemFont(ofSize: 17).lineHeight/2
        textDescriptor.set(textShadowOpened: true)
        textDescriptor.positionPriority = .low
        textDescriptor.textFont = UIFont.systemFont(ofSize: 17)
        textDescriptor.animationDuration = Double(arc4random()%10 + 5)
        textDescriptor.barrageCellClass = SwiftBarrageTextCell.classForCoder()
        if statusFlag {
            manager.render(barrageDescriptor: textDescriptor)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.addText()
            }
        }
    }
    
    func addVerticalText() {
        let descriptor = SwiftBarrageVerticalTextDescriptor()
        descriptor.text = "SwiftBarrage"
        descriptor.textColor = .yellow
        descriptor.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
        descriptor.positionPriority = .middle
        descriptor.horizontalSpace = 3
        descriptor.verticalSpace = 3
        descriptor.textFont = UIFont.systemFont(ofSize: 17)
        descriptor.animationDuration = 5
        descriptor.barrageCellClass = SwiftBarrageVerticalTextCell.classForCoder()
        if statusFlag {
            manager.render(barrageDescriptor: descriptor)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.addVerticalText()
            }
        }
    }
    
    func addGif() {
        let descriptor = SwiftBarrageGifDescriptor()
        if let gifPath = Bundle.main.path(forResource: "xuanzhuan", ofType: "gif") {
            let url = URL.init(fileURLWithPath: gifPath)
            if let gifData = try? Data(contentsOf: url) {
                let image = YYImage(data: gifData, scale: 4)
                descriptor.image = image
            }
        }
        descriptor.positionPriority = .high
        descriptor.animationDuration = Double(arc4random()%5 + 5)
        descriptor.barrageCellClass = SwiftBarrageGifCell.classForCoder()
        if statusFlag {
            manager.render(barrageDescriptor: descriptor)
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.addGif()
            }
        }
    }
    
    func addMixedTextAndImage() {
        let descriptor = SwiftBarrageTextDescriptor()
        descriptor.shouldRemoveSubViewsAndSublayers = false
        let rate:CGFloat = 7.0
        if let path = Bundle.main.path(forResource: "demoIcon@2x", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            if let data = try? Data(contentsOf: url) {
                let image = YYImage(data: data, scale: rate)
                image?.preloadAllAnimatedImageFrames = true
                let imageView = YYAnimatedImageView(image: image)
                let attributedString = NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: .center, attachmentSize: imageView.frame.size, alignTo: UIFont.boldSystemFont(ofSize: 25), alignment: .center)
                attributedString.append(NSAttributedString(string: "SwiftBarrage", attributes: [.foregroundColor:UIColor.red]))
                let image2 = YYImage(data: data, scale: rate)
                image2?.preloadAllAnimatedImageFrames = true
                let imageView2 = YYAnimatedImageView(image: image)
                let attributedString2 = NSMutableAttributedString.yy_attachmentString(withContent: imageView2, contentMode: .center, attachmentSize: imageView2.frame.size, alignTo: UIFont.boldSystemFont(ofSize: 25), alignment: .center)
                attributedString.append(attributedString2)
                let image3 = YYImage(data: data, scale: rate)
                image3?.preloadAllAnimatedImageFrames = true
                let imageView3 = YYAnimatedImageView(image: image)
                let attributedString3 = NSMutableAttributedString.yy_attachmentString(withContent: imageView3, contentMode: .center, attachmentSize: imageView3.frame.size, alignTo: UIFont.boldSystemFont(ofSize: 25), alignment: .center)
                attributedString.append(attributedString3)
                attributedString.addAttribute(.strokeWidth, value: NSNumber(value: -1), range: NSRange(location: 0, length: attributedString.length))
                attributedString.addAttribute(.strokeColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 25), range: NSRange(location: 0, length: attributedString.length))
                descriptor.attributedText = attributedString
            }
            descriptor.textColor = .red
            descriptor.positionPriority = .high
            descriptor.animationDuration = Double(arc4random()%5 + 5)
            descriptor.barrageCellClass = SwiftBarrageMixedImageAndTextCell.classForCoder()
            if statusFlag {
                manager.render(barrageDescriptor: descriptor)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.addMixedTextAndImage()
                }
            }
        }
    }
    
    func addNoble() {
        let descriptor = SwiftBarrageBecomeNobleDescriptor()

        let attributedString = NSMutableAttributedString(string: "SwiftBarrage~Mira直播~荣誉出品~")
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 1, length: 9))
        attributedString.addAttribute(.foregroundColor, value: UIColor.cyan, range: NSRange(location: 11, length: 4))
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange(location: 16, length: 4))
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17.0), range: NSRange(location: 0, length: attributedString.length))
        descriptor.attributedText = attributedString
        let bannerHeight:CGFloat = 185.0/2.0
        let minOrginY = view.frame.midY - bannerHeight
        let maxOrginY = view.frame.midY + bannerHeight
        descriptor.renderRange = Range<CGFloat>.init(uncheckedBounds: (minOrginY,maxOrginY))
        descriptor.positionPriority = .veryHigh
        descriptor.animationDuration = 7
        descriptor.barrageCellClass = SwiftBarrageBecomeNobleCell.classForCoder()
        descriptor.backgroundImage = #imageLiteral(resourceName: "background")
        if statusFlag {
            manager.render(barrageDescriptor: descriptor)
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.addNoble()
            }
        }
        if self.stopY == 0 {
            self.stopY = bannerHeight
        } else {
            self.stopY = 0
        }
    }

    @IBAction func startButtonCliked(_ sender: UIButton) {
        if !statusFlag {
            statusFlag = true
            manager.start()
            addBarrage()
        }
    }
    @IBAction func pauseButtonClicked(_ sender: UIButton) {
        if statusFlag {
            statusFlag = false
            manager.pause()
        }
    }
    
    @IBAction func resumeButtonClicked(_ sender: UIButton) {
        if !statusFlag {
            statusFlag = true
            manager.resume()
            addBarrage()
        }
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        if statusFlag {
            statusFlag = false
            manager.stop()
        }
    }
}

