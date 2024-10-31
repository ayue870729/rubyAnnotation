//
//  RubyLabel.swift
//  jp22
//
//  Created by a01 on 2024/10/29.
//

import Foundation
import UIKit


class RubyLabel: UILabel {
        
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    // ルビを表示
    override func draw(_ rect: CGRect) {
        //super.draw(rect) //3
        
        // context allows you to manipulate the drawing context (i'm setup to draw or bail out)
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }
//        guard let string = self.text else { return }
        
        guard let attributedText = self.attributedText else { return }
        let attributed = NSMutableAttributedString(attributedString: attributedText) //4
        
        let path = CGMutablePath()
        context.textMatrix = CGAffineTransform.identity;
        context.translateBy(x: 0, y: self.bounds.size.height);
        context.scaleBy(x: 1.0, y: -1.0);
        path.addRect(self.bounds)
        attributed.addAttribute(NSAttributedString.Key.verticalGlyphForm, value: false, range: NSMakeRange(0, attributed.length))

        
        attributed.addAttributes([NSAttributedString.Key.font : self.font!], range: NSMakeRange(0, attributed.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attributed)
        
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0,attributed.length), path, nil)
        
        // Check need for truncate tail
        //6
        if (CTFrameGetVisibleStringRange(frame).length as Int) < attributed.length {
            // Required truncate
            let linesNS: NSArray  = CTFrameGetLines(frame)
            let linesAO: [AnyObject] = linesNS as [AnyObject]
            var lines: [CTLine] = linesAO as! [CTLine]
            
            let boundingBoxOfPath = path.boundingBoxOfPath
            
            let lastCTLine = lines.removeLast() //7
            
            let truncateString:CFAttributedString = CFAttributedStringCreate(nil, "\u{2026}" as CFString, CTFrameGetFrameAttributes(frame))
            let truncateToken:CTLine = CTLineCreateWithAttributedString(truncateString)
            
            let lineWidth = CTLineGetTypographicBounds(lastCTLine, nil, nil, nil)
            let tokenWidth = CTLineGetTypographicBounds(truncateToken, nil, nil, nil)
            let widthTruncationBegins = lineWidth - tokenWidth
            if let truncatedLine = CTLineCreateTruncatedLine(lastCTLine, widthTruncationBegins, .end, truncateToken) {
                lines.append(truncatedLine)
            }
            
            var lineOrigins = Array<CGPoint>(repeating: CGPoint.zero, count: lines.count)
            CTFrameGetLineOrigins(frame, CFRange(location: 0, length: lines.count), &lineOrigins)
            for (index, line) in lines.enumerated() {
                context.textPosition = CGPoint(x: lineOrigins[index].x + boundingBoxOfPath.origin.x, y:lineOrigins[index].y + boundingBoxOfPath.origin.y)
                CTLineDraw(line, context)
            }
        }
        else {
            // Not required truncate
            CTFrameDraw(frame, context)
        }
    }
    
    //8
    override var intrinsicContentSize: CGSize {
        let baseSize = super.intrinsicContentSize
        return CGSize(width: baseSize.width, height: baseSize.height * 1.0)
    }
}
