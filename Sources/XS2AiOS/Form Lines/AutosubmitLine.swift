import UIKit
import NVActivityIndicatorView

class AutosubmitLine: UIViewController, FormLine {
	var actionDelegate: ActionDelegate?
	var networkDelegate: NetworkNotificationDelegate?

	/// The interval in milliseconds after which the autosubmit is triggered
	private let interval: Int
	
	let indicatorView = XS2AiOS.shared.loadingStateProvider.loadingIndicatorView

	var timer = Timer()

	/**
	 - Parameters:
	   - interval: The interval in milliseconds after which the autosubmit is triggered
	*/
	init(interval: Int) {
		self.interval = interval
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func submit() {
		actionDelegate?.sendAction(actionType: .autosubmit, withLoadingIndicator: false, additionalPayload: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		indicatorView.stopAnimating()
		timer.invalidate()
	}
	
	@objc func appMovedToBackground() {
		timer.invalidate()
		networkDelegate?.cancelNetworkTask()
	}
	
	@objc func appMovedToForeground() {
		submit()
	}
	
	override func viewDidLoad() {
		indicatorView.startAnimating()

		view.addSubview(indicatorView)
		indicatorView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			view.heightAnchor.constraint(equalTo: indicatorView.heightAnchor),
		])
		
		NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)

		timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.interval / 1000), target: self, selector: #selector(submit), userInfo: nil, repeats: false)
	}
}
