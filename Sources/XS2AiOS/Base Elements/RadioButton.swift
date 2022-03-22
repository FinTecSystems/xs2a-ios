import UIKit

class RadioButton: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	func commonInit() -> Void {
		heightAnchor.constraint(equalToConstant: 40).isActive = true
		if #available(iOS 11.0, *) {
			contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.leading
		} else {
			contentHorizontalAlignment = .left
		}
		contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
		titleLabel?.adjustsFontSizeToFitWidth = true
		titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if let imgView = imageView {
			let h = imgView.frame.height
			var insets: UIEdgeInsets = imageEdgeInsets
			insets.right = bounds.width - (h + contentEdgeInsets.left + contentEdgeInsets.right)
			imageEdgeInsets = insets
		}
	}
}
