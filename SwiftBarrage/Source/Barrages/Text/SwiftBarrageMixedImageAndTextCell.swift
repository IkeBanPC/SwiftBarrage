//
//  SwiftBarrageMixedImageAndTextCell.swift
//  SwiftBarrage
//
//  Created by Isaac on 2018/6/1.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

public class SwiftBarrageMixedImageAndTextCell: SwiftBarrageTextCell {
    var mixedImageAndTextLabel: YYLabel
    public required init() {
        mixedImageAndTextLabel = YYLabel()
        super.init()
        addSubview(mixedImageAndTextLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
         mixedImageAndTextLabel = YYLabel()
        super.init(coder: aDecoder)
        addSubview(mixedImageAndTextLabel)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        mixedImageAndTextLabel.attributedText = nil
    }
    override func updateSubviewsData() {
        mixedImageAndTextLabel.attributedText = textDescriptor?.attributedText
    }
    override func layoutContentSubviews() {
        if let descriptor = self.textDescriptor {
            let cellSize = mixedImageAndTextLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            mixedImageAndTextLabel.frame = CGRect(x: 0, y: 0, width: cellSize.width+2*descriptor.horizontalSpace, height: cellSize.height+2*descriptor.verticalSpace)
        }
    }
}
