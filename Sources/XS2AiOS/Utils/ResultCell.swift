import UIKit

class ResultCell: UITableViewCell {
	@IBOutlet weak var resultLabelLine1: UILabel!
	@IBOutlet weak var resultLabelLine2: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		guard let resultLabelLine1 = resultLabelLine1 else {
			return
		}
		
		guard let resultLabelLine2 = resultLabelLine2 else {
			return
		}
		
		resultLabelLine1.textColor = XS2AiOS.shared.styleProvider.textColor
		resultLabelLine1.translatesAutoresizingMaskIntoConstraints = false
		resultLabelLine1.numberOfLines = 1
		resultLabelLine1.baselineAdjustment = .alignCenters
		resultLabelLine1.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 15, ofWeight: nil)
		
		resultLabelLine2.textColor = XS2AiOS.shared.styleProvider.textColor
		resultLabelLine2.translatesAutoresizingMaskIntoConstraints = false
		resultLabelLine2.numberOfLines = 1
		resultLabelLine2.baselineAdjustment = .alignCenters
		resultLabelLine2.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 12, ofWeight: nil)
		
		NSLayoutConstraint.activate([
			// Line 1
			resultLabelLine1.widthAnchor.constraint(equalTo: self.widthAnchor),
			resultLabelLine1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
			resultLabelLine1.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			resultLabelLine1.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
			// Line 2
			resultLabelLine2.widthAnchor.constraint(equalTo: self.widthAnchor),
			resultLabelLine2.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
			resultLabelLine2.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			resultLabelLine2.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
		])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
