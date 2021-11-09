import UIKit

/// Class for a single flicker container
/// Optionally with a alignment triangle at the top
class FlickerContainer: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	/**
	- Parameters:
		- withTriangle: Whether to add a triangle to the view (used for alignment of the TAN device)
		- alignment: Whether to align the container vertically or horizontally
	*/
	convenience init(withTriangle: Bool = false, alignment: FlickerAlignment = .horizontal) {
		self.init(frame: .zero)
		
		if withTriangle == true {
			var triangle = UIImage(named: "flicker_triangle", in: .current, compatibleWith: nil)
			
			if alignment == .vertical {
				triangle = UIImage(cgImage: triangle!.cgImage!, scale: 1.0, orientation: .right)
			}
			
			let triangleImageView = UIImageView(image: triangle)
			self.addSubview(triangleImageView)
			self.translatesAutoresizingMaskIntoConstraints = false
			triangleImageView.translatesAutoresizingMaskIntoConstraints = false
			triangleImageView.contentMode = .scaleAspectFit
			
			switch alignment {
			case .horizontal:
				NSLayoutConstraint.activate([
					triangleImageView.topAnchor.constraint(equalTo: self.topAnchor),
					triangleImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25),
					triangleImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
				])
			case .vertical:
				NSLayoutConstraint.activate([
					triangleImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
					triangleImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5),
					triangleImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1),
				])
			}
			

			
			if triangleImageView.superview != nil {
				triangleImageView.centerYAnchor.constraint(lessThanOrEqualTo: triangleImageView.superview!.centerYAnchor).isActive = true
				
				if alignment == .horizontal {
					/// Only in case of horizontal alignment we need to add an XAnchor constraint
					triangleImageView.centerXAnchor.constraint(lessThanOrEqualTo: triangleImageView.superview!.centerXAnchor).isActive = true
				}
			}
		}
	}
}
