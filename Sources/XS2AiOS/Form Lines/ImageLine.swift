import UIKit

class ImageLine: UIViewController, FormLine {
	var actionDelegate: ActionDelegate?
	
	private var imageElement: UIImage
	private var imageView: UIImageView
    
    private var imageDescription: String
	
	/**
	 - Parameters:
	   - data: The base64 encoded image data
	*/
    init(data: String, description: String) {
		imageView = UIImageView()
        imageDescription = description
		
		if let base64ImageData = imageForBase64String(data) {
			imageElement = base64ImageData
		} else {
			imageElement = UIImage()
		}
		
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
        
        setupAccessibility()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    private func setupAccessibility() {
        view.isAccessibilityElement = true
        view.accessibilityTraits = [.image]
        view.accessibilityLabel = imageDescription
    }
}
