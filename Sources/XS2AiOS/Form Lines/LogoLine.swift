import UIKit
import SafariServices

class LogoLine: UIViewController, FormLine {
	/// Static FormLine Element, protocol variables will never be non-nil for LogoLine
	var actionDelegate: ActionDelegate? = nil
	
	/// Function called when the logo is tapped
	/// Opens the imprint information
	@objc func logoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
		let alert = UIAlertController(
			title: Strings.Alert.Imprint.title,
			message: Strings.Alert.Imprint.message,
			preferredStyle: .alert
		)
		
		/// Close button
		alert.addAction(
			UIAlertAction(
				title: Strings.Alert.close,
				style: .cancel
			)
		)
		
		
		/// "Learn More" Button linking to webpage
		alert.addAction(
			UIAlertAction(
				title: Strings.Alert.Imprint.linkText,
				style: .default,
				handler: { _ in
					let safariVC = SFSafariViewController(url: URL(string: Strings.Alert.Imprint.link)!)
					self.present(safariVC, animated: true, completion: nil)
				}
			)
		)

		self.present(alert, animated: true, completion: nil)
	}

	override func viewDidLoad() {
		guard let url = URL(string: "https://api.xs2a.com/img/mobile-sdks/ios/\(XS2AiOS.shared.styleProvider.logoVariation.rawValue).pdf") else {
			fatalError("Logo not found.")
		}

		let imageView = UIImageView()
		imageView.load(url: url)
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(logoTapped(tapGestureRecognizer:)))
		imageView.isUserInteractionEnabled = true
		imageView.addGestureRecognizer(tapGestureRecognizer)
		
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(imageView)
		
		NSLayoutConstraint.activate([
			imageView.heightAnchor.constraint(equalToConstant: 70),
			imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			view.heightAnchor.constraint(equalTo: imageView.heightAnchor),
		])
	}
}
