import UIKit

enum BorderAnimationType {
	case didStart
	case didEnd
}

func getBorderWidthAnimation(type: BorderAnimationType) -> CABasicAnimation {
	let borderWidthAnimation: CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
	
	switch type {
	case .didStart:
		borderWidthAnimation.fromValue = 0
		borderWidthAnimation.toValue = 2
	case .didEnd:
		borderWidthAnimation.fromValue = 2
		borderWidthAnimation.toValue = 0
	}
	
	borderWidthAnimation.duration = 0.15
	
	return borderWidthAnimation
}
