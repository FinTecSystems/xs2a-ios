import UIKit

class ResultCell: UITableViewCell {
	@IBOutlet weak var resultTextLabel: UILabel!

	override func awakeFromNib() {
        super.awakeFromNib()
		if let resultTextLabel = resultTextLabel {
			resultTextLabel.textColor = XS2AiOS.shared.styleProvider.textColor
			resultTextLabel.translatesAutoresizingMaskIntoConstraints = false
			resultTextLabel.baselineAdjustment = .alignCenters
			resultTextLabel.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 14, ofWeight: nil)
			NSLayoutConstraint.activate([
				resultTextLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
				resultTextLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
				resultTextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
				resultTextLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			])
		}
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
