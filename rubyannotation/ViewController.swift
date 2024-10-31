//
//  ViewController.swift
//  rubyannotation
//
//  Created by a01 on 2024/10/31.
//

import UIKit

struct Sentence: Codable {
    let sen: String
    let rubyArr: [Ruby]
}
struct Ruby: Codable {
    let start: Int
    let length: Int
    let rt: String
}

class ViewController: UIViewController {

    let str = """
{"sen": "この小説の中で，地獄で苦しむ罪人カンダタは，はるか高い極楽から下がってきた1本のクモの糸を上っていくが，欲を出したために糸は切れてしまい，再び地獄に落ちてしまう。", "rubyArr": [{"start": 2, "length": 1, "rt": "しょう"}, {"start": 3, "length": 1, "rt": "せつ"}, {"start": 5, "length": 1, "rt": "なか"}, {"start": 8, "length": 1, "rt": "じ"}, {"start": 9, "length": 1, "rt": "ごく"}, {"start": 11, "length": 1, "rt": "くる"}, {"start": 14, "length": 2, "rt": "ざいにん"}, {"start": 25, "length": 1, "rt": "たか"}, {"start": 27, "length": 2, "rt": "ごくらく"}, {"start": 31, "length": 1, "rt": "さ"}, {"start": 38, "length": 1, "rt": "ぽん"}, {"start": 43, "length": 1, "rt": "いと"}, {"start": 45, "length": 1, "rt": "のぼ"}, {"start": 52, "length": 1, "rt": "よく"}, {"start": 54, "length": 1, "rt": "だ"}, {"start": 60, "length": 1, "rt": "いと"}, {"start": 62, "length": 1, "rt": "き"}, {"start": 69, "length": 1, "rt": "ふたた"}, {"start": 71, "length": 1, "rt": "じ"}, {"start": 72, "length": 1, "rt": "ごく"}, {"start": 74, "length": 1, "rt": "お"}]}
"""
    var sen: Sentence!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        let decoder = JSONDecoder()
        
        let data = str.data(using: .utf8)!
        sen = try? decoder.decode(Sentence.self, from: data)
        
        let attributedString = createRubyAttributedString(from: sen)
        
        //how can I calculate the real text heigt?
        let systemLabel = UILabel(frame: CGRect(x: 20, y: 60, width: 300, height: 250))
        systemLabel.numberOfLines = 0
        systemLabel.attributedText = attributedString
        view.addSubview(systemLabel)
        
        //how can I calculate the real text heigt?
        let cusRubyLabel = RubyLabel(frame: CGRect(x: 20, y: 360, width: 300, height: 250))
        cusRubyLabel.numberOfLines = 0
        cusRubyLabel.attributedText = attributedString
        cusRubyLabel.attributedText = attributedString
        view.addSubview(cusRubyLabel)
        print(cusRubyLabel.intrinsicContentSize.height)
    }
    
    
    

    func createRubyAttributedString(from sentence: Sentence) -> NSAttributedString {
        let fullString = NSMutableAttributedString(string: sentence.sen)
        
        for rubyItem in sentence.rubyArr {
            let start = rubyItem.start
            let length = rubyItem.length
            let rubyText = rubyItem.rt
            let rubyAttribute: [CFString: Any] =  [
                kCTRubyAnnotationSizeFactorAttributeName: 0.5,
                kCTForegroundColorAttributeName: UIColor.darkGray
            ]
            let rubyAnnotation = CTRubyAnnotationCreateWithAttributes(
                .auto, .auto, .before, rubyText as CFString, rubyAttribute as CFDictionary
            )
            let rubyRange = NSRange(location: start, length: length)
            fullString.addAttributes(
                [kCTRubyAnnotationAttributeName as NSAttributedString.Key: rubyAnnotation],
                range: rubyRange
            )
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.lineSpacing = 15

        fullString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: fullString.length))
        return fullString
    }
}

