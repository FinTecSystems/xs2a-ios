import UIKit

enum BorderAnimationType {
	case didStart
	case didEnd
}

func getBorderWidthAnimation(type: BorderAnimationType) -> CAAnimation {
	let borderWidthAnimation: CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")

	switch type {
	case .didStart:
		borderWidthAnimation.fromValue = XS2AiOS.shared.styleProvider.inputBorderWidth
		borderWidthAnimation.toValue = XS2AiOS.shared.styleProvider.inputBorderWidthActive
	case .didEnd:
		borderWidthAnimation.fromValue = XS2AiOS.shared.styleProvider.inputBorderWidthActive
		borderWidthAnimation.toValue = XS2AiOS.shared.styleProvider.inputBorderWidth
	}

	borderWidthAnimation.duration = 0.15

	return borderWidthAnimation
}

func getBorderColorAnimation(type: BorderAnimationType) -> CAAnimation {
	let animation: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")

	switch type {
	case .didStart:
		animation.fromValue = XS2AiOS.shared.styleProvider.inputBorderColor.cgColor
		animation.toValue = XS2AiOS.shared.styleProvider.tintColor.cgColor
	case .didEnd:
		animation.fromValue = XS2AiOS.shared.styleProvider.tintColor.cgColor
		animation.toValue = XS2AiOS.shared.styleProvider.inputBorderColor.cgColor
	}

	animation.duration = 0.15

	return animation
}

func getBorderAnimation(type: BorderAnimationType) -> CAAnimation {
	let group = CAAnimationGroup()
	group.animations = [getBorderWidthAnimation(type: type), getBorderColorAnimation(type: type)]
	group.duration = 0.15

	return group
}
