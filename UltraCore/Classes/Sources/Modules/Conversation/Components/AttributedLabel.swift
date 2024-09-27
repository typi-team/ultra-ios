//
//  AttributedLabel.swift
//  UltraCore
//
//  Created by Typi on 08.02.2024.
//

import UIKit

class AttributedLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        numberOfLines = 0
        isUserInteractionEnabled = true
    }
    
    override var attributedText: NSAttributedString? {
        get {
            super.attributedText
        }
        set {
            super.attributedText = {
                guard let newValue = newValue else {
                    return NSAttributedString(string: "")
                }
                let text = NSMutableAttributedString(attributedString: newValue)
                let links = getLinks(attributedString: text)
                for link in links {
                    text.addAttributes(hyperlinkAttributes, range: link.range)
                    text.addAttributes([.hyperLink : link.link], range: link.range)
                }
                text.enumerateAttribute(.font, in: NSRange(location: 0, length: text.length), options: .longestEffectiveRangeNotRequired) { value, subrange, _ in
                    guard
                        value == nil,
                        let font = font
                    else {
                        return
                    }
                    text.addAttribute(.font, value: font, range: subrange)
                }
                return text
            }()
        }
    }
    
    var hyperlinkAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBlue]
    var didTapURL: ((URL) -> Void) = { url in
        guard UIApplication.shared.canOpenURL(url) else {
            PP.info("Can't open the URL: \(url)")
            return
        }
        UIApplication.shared.open(url)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let url = self.url(at: touches) {
            didTapURL(url)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
    
    private func url(at touches: Set<UITouch>) -> URL? {
        guard let attributedText = attributedText, attributedText.length > 0 else {
            return nil
        }
        guard let touchLocation = touches.sorted(by: { $0.timestamp < $1.timestamp }).last?.location(in: self) else {
            return nil
        }
        guard let textStorage = prepareTextStorage() else {
            return nil
        }
        let layoutManager = textStorage.layoutManagers[0]
        let textContainer = layoutManager.textContainers[0]
        let characterIndex = layoutManager.characterIndex(for: touchLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        guard characterIndex >= 0, characterIndex != NSNotFound else {
            return nil
        }
        
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: characterIndex, length: 1), actualCharacterRange: nil)
        let characterRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        guard characterRect.contains(touchLocation) else {
            return nil
        }
        
        return textStorage.attribute(.hyperLink, at: characterIndex, effectiveRange: nil) as? URL
    }
    
    private func prepareTextStorage() -> NSTextStorage? {
        guard let attributedText = attributedText, attributedText.length > 0 else {
            return nil
        }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        let textStorage = NSTextStorage(string: "")
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineBreakMode = lineBreakMode
        textContainer.size = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).size
        textStorage.setAttributedString(attributedText)
        
        return textStorage
    }
    
    private struct LinkData {
        let link: URL
        let range: NSRange
    }
    
    private func getLinks(attributedString: NSAttributedString) -> [LinkData] {
        let checkTypes: NSTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult.CheckingType.phoneNumber.rawValue
        guard let detector = try? NSDataDetector(types: checkTypes) else {
            return []
        }
        
        let text = attributedString.string
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        var ranges: [LinkData] = []
        for match in matches {
            if let url = match.url {
                ranges.append(.init(link: url, range: match.range))
            }
            if
                let phone = match.phoneNumber,
                let phoneURL = URL(string: "tel://\(phone.components(separatedBy: .whitespaces).joined())")
            {
                ranges.append(.init(link: phoneURL, range: match.range))
            }
        }
        attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length), options: .longestEffectiveRangeNotRequired) { value, subrange, _ in
            if let url = value as? URL {
                ranges.append(.init(link: url, range: subrange))
            }
        }
        return ranges
    }
    
}

extension NSAttributedString.Key {
    static let hyperLink = NSAttributedString.Key("hyperlink")
}
