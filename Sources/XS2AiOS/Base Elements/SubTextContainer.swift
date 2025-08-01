import UIKit

class SubTextContainer: UIView {
    private let contentView: UIView

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = XS2A.shared.styleProvider.font.getFont(
            ofSize: 12, ofWeight: nil)
        label.textColor = XS2A.shared.styleProvider.placeholderColor
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    func showMessage(
        _ message: String?, isError: Bool = true, prefix: String = ""
    ) {
        if let message = message {
            messageLabel.text = prefix + message
            messageLabel.textColor =
                isError
                ? XS2A.shared.styleProvider.errorColor
                : XS2A.shared.styleProvider.placeholderColor
            messageLabel.isHidden = false
        } else {
            messageLabel.isHidden = true
        }
    }

    init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(contentView)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),

            messageLabel.topAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
