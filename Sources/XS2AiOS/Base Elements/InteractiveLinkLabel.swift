//
//  InteractiveLinkLabel.swift
//
//  Created by Steven Curtis on 31/10/2019.
//  Copyright https://github.com/stevencurtis/ClickableLabel/blob/master/ClickableLabel/InteractiveLinkLabel.swift
//
import UIKit

class InteractiveLinkLabel: UILabel {
	var openLinkDelegate: OpenLinkDelegate?

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
		self.configure()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configure()
	}
	
	func configure() {
		isUserInteractionEnabled = true
	}
	
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let superBool = super.point(inside: point, with: event)
        if event == nil { return superBool } // Workaround for VoiceOver
		
		// Configure NSTextContainer
		let textContainer = NSTextContainer(size: bounds.size)
		textContainer.lineFragmentPadding = 0.0
		textContainer.lineBreakMode = lineBreakMode
		textContainer.maximumNumberOfLines = numberOfLines
		
		// Configure NSLayoutManager and add the text container
		let layoutManager = NSLayoutManager()
		layoutManager.addTextContainer(textContainer)
		
		guard let attributedText = attributedText else {return false}
		
		// Configure NSTextStorage and apply the layout manager
		let textStorage = NSTextStorage(attributedString: attributedText)
		textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSMakeRange(0, attributedText.length))
		textStorage.addLayoutManager(layoutManager)
		
		// get the tapped character location
		let locationOfTouchInLabel = point
		
		// account for text alignment and insets
		let textBoundingBox = layoutManager.usedRect(for: textContainer)
		var alignmentOffset: CGFloat!
		switch textAlignment {
		case .left, .natural, .justified:
			alignmentOffset = 0.0
		case .center:
			alignmentOffset = 0.5
		case .right:
			alignmentOffset = 1.0
		@unknown default:
			fatalError()
		}
		
		let xOffset = ((bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
		let yOffset = ((bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
		let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - xOffset, y: locationOfTouchInLabel.y - yOffset)
		
		// work out which character was tapped
		let characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
		
		// work out how many characters are in the string up to and including the line tapped, to ensure we are not off the end of the character string
		let lineTapped = Int(ceil(locationOfTouchInLabel.y / font.lineHeight)) - 1
		let rightMostPointInLineTapped = CGPoint(x: bounds.size.width, y: font.lineHeight * CGFloat(lineTapped))
		let charsInLineTapped = layoutManager.characterIndex(for: rightMostPointInLineTapped, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
		
		guard characterIndex < charsInLineTapped else {return false}
		
		let attributeName = NSAttributedString.Key.attachment
		
		let attributeValue = self.attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil)

		
		if let value = attributeValue {
			if let url = value as? URL {
				openLinkDelegate?.openLink(url: url)
			}
		}
		
		return superBool
	}
}
