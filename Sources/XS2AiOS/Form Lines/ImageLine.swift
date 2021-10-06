import UIKit

class ImageLine: UIViewController, FormLine {
	var actionDelegate: ActionDelegate?
	
	let multiFormName: String?
	let multiFormValue: String?
	
	private var imageElement: UIImage
	private var imageView: UIImageView
	
	/**
	 - Parameters:
	   - data: The base64 encoded image data
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(data: String, multiFormName: String?, multiFormValue: String?) {
		imageView = UIImageView()
		
		if let base64ImageData = imageForBase64String(data) {
			imageElement = base64ImageData
		} else {
			imageElement = UIImage()
		}
		
		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue
		
		super.init(nibName: nil, bundle: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageView = UIImageView(image: imageElement)
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(imageView)
		
		NSLayoutConstraint.activate([
			imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			view.heightAnchor.constraint(equalTo: imageView.heightAnchor),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
