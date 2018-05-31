//
//  SwiftBarrageTextDescriptor.swift
//  SwiftBarrage
//
//  Created by Isaac Pan on 2018/3/14.
//  Copyright © 2018年 IsaacPan. All rights reserved.
//

import UIKit
public class SwiftBarrageTextDescriptor: SwiftBarrageDescriptor {
    var textAttribute: [NSAttributedStringKey:Any]
    var textFont: UIFont {
        didSet {
            textAttribute[NSAttributedStringKey.font] = textFont
        }
    }
    var textColor: UIColor {
        didSet {
            textAttribute[NSAttributedStringKey.foregroundColor] = textColor
        }
    }
    var textShadowOpened: Bool
    var shadowColor: UIColor {
        didSet {
            if !textShadowOpened {
                textAttribute[NSAttributedStringKey.strokeColor] = strokeColor
            }
        }
    }
    var shadowOffset: CGSize
    var shadowRadius: CGFloat
    var shadowOpacity: Float
    var strokeColor: UIColor? {
        didSet {
            if let color = strokeColor {
                textAttribute[NSAttributedStringKey.strokeColor] = color
            }
        }
    }
    var strokeWidth: Float? {
        didSet {
            if let width = strokeWidth {
                textAttribute[NSAttributedStringKey.strokeWidth] = NSNumber(value: width)
            }
        }
    }
    var text: String?
    
    var attributedText: NSAttributedString? {
        get {
            let tempAttributedText = NSAttributedString(string: text ?? "", attributes: textAttribute)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.baseWritingDirection = .leftToRight
            let attributedText = NSMutableAttributedString(attributedString: tempAttributedText)
            attributedText.addAttributes([
                NSAttributedStringKey.paragraphStyle:paragraphStyle,
                ], range: NSRange(location: 0, length: attributedText.string.count))
            return  attributedText.copy() as? NSAttributedString
        }
    }


    override init() {
        textAttribute = [NSAttributedStringKey:Any]()
        shadowColor = .white
        shadowOffset = CGSize()
        shadowRadius = 0
        shadowOpacity = 0
        textColor = .black
        textFont = UIFont.systemFont(ofSize: 17)
        textShadowOpened = false
        super.init()
    }
    
    public func set(textShadowOpened: Bool) {
        self.textShadowOpened = textShadowOpened
        if textShadowOpened {
            textAttribute.removeValue(forKey: NSAttributedStringKey.strokeColor)
            textAttribute.removeValue(forKey: NSAttributedStringKey.strokeWidth)
        }
    }
}

/**
 * API:  Character Attributes , NSAttributedString 共有21个属性
 *
 * 1. NSFontAttributeName               ->设置字体属性，默认值：字体：Helvetica(Neue) 字号：12
 *
 *
 * 2. NSParagraphStyleAttributeName     ->设置文本段落排版格式，取值为 NSParagraphStyle 对象(详情见下面的API说明)
 *
 *
 * 3. NSForegroundColorAttributeName    ->设置字体颜色，取值为 UIColor对象，默认值为黑色
 *
 *
 * 4. NSBackgroundColorAttributeName    ->设置字体所在区域背景颜色，取值为 UIColor对象，默认值为nil, 透明色
 *
 *
 * 5. NSLigatureAttributeName           ->设置连体属性，取值为NSNumber 对象(整数)，0 表示没有连体字符，1 表示使用默认的连体字符
 *
 *
 * 6. NSKernAttributeName               ->设置字符间距，取值为 NSNumber 对象（整数），正值间距加宽，负值间距变窄
 *
 *
 * 7. NSStrikethroughStyleAttributeName ->设置删除线，取值为 NSNumber 对象（整数）
 *
 *
 * 8. NSStrikethroughColorAttributeName ->设置删除线颜色，取值为 UIColor 对象，默认值为黑色
 *
 *
 * 9. NSUnderlineStyleAttributeName     ->设置下划线，取值为 NSNumber 对象（整数），枚举常量 NSUnderlineStyle中的值，与删除线类似
 *
 *
 * 10. NSUnderlineColorAttributeName    ->设置下划线颜色，取值为 UIColor 对象，默认值为黑色
 *
 *
 * 11. NSStrokeWidthAttributeName       ->设置笔画宽度(粗细)，取值为 NSNumber 对象（整数），负值填充效果，正值中空效果
 *
 *
 * 12. NSStrokeColorAttributeName       ->填充部分颜色，不是字体颜色，取值为 UIColor 对象
 *
 *
 * 13. NSShadowAttributeName            ->设置阴影属性，取值为 NSShadow 对象
 *
 *
 * 14. NSTextEffectAttributeName        ->设置文本特殊效果，取值为 NSString 对象，目前只有图版印刷效果可用
 *
 *
 * 15. NSBaselineOffsetAttributeName    ->设置基线偏移值，取值为 NSNumber （float）,正值上偏，负值下偏
 *
 *
 * 16. NSObliquenessAttributeName       ->设置字形倾斜度，取值为 NSNumber （float）,正值右倾，负值左倾
 *
 *
 * 17. NSExpansionAttributeName         ->设置文本横向拉伸属性，取值为 NSNumber （float）,正值横向拉伸文本，负值横向压缩文本
 *
 *
 * 18. NSWritingDirectionAttributeName  ->设置文字书写方向，从左向右书写或者从右向左书写
 *
 *
 * 19. NSVerticalGlyphFormAttributeName ->设置文字排版方向，取值为 NSNumber 对象(整数)，0 表示横排文本，1 表示竖排文本
 *
 *
 * 20. NSLinkAttributeName              ->设置链接属性，点击后调用浏览器打开指定URL地址
 *
 *
 * 21. NSAttachmentAttributeName        ->设置文本附件,取值为NSTextAttachment对象,常用于文字图片混排
 *
 */
