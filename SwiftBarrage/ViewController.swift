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
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = SwiftBarrageManager()
        self.view.addSubview(manager.renderView)
        manager.renderView.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height-64-80)
        manager.renderView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addBarrage() {
        let count = manager.renderView.animationCells.count
        self.title = "现在有\(count)条弹幕"
        let textDescriptor = SwiftBarrageTextDescriptor()
        textDescriptor.text = "SwiftBarrage"
        textDescriptor.textColor = .cyan
        textDescriptor.set(textShadowOpened: true)
        textDescriptor.positionPriority = .low
        textDescriptor.textFont = UIFont.systemFont(ofSize: 17)
        textDescriptor.animationDuration = Double(arc4random()%10 + 5)
        textDescriptor.barrageCellClass = SwiftBarrageTextCell.classForCoder()
        manager.render(barrageDescriptor: textDescriptor)
        if statusFlag {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                self.addBarrage()
            }
        }
    }

    @IBAction func startButtonCliked(_ sender: UIButton) {
        manager.start()
        statusFlag = true
        addBarrage()
    }
    @IBAction func pauseButtonClicked(_ sender: UIButton) {
        statusFlag = false
        manager.pause()
    }
    
    @IBAction func resumeButtonClicked(_ sender: UIButton) {
        statusFlag = true
        manager.resume()
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        statusFlag = false
        manager.stop()
    }
}

