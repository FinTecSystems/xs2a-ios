import UIKit

extension UIStackView {
    func addCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
        if #available(iOS 11.0, *) {
            self.setCustomSpacing(spacing, after: arrangedSubview)
        } else {
            let separatorView = UIView(frame: .zero)
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            
            switch axis {
            case .horizontal:
            separatorView.widthAnchor.constraint(equalToConstant: spacing).isActive = true
            case .vertical:
            separatorView.heightAnchor.constraint(equalToConstant: spacing).isActive = true
            }
            
            if let index = self.arrangedSubviews.firstIndex(of: arrangedSubview) {
                insertArrangedSubview(separatorView, at: index + 1)
            }
        }
    }
}
