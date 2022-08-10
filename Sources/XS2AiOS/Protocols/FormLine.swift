import UIKit

/// Protocol for all FormLine Elements
protocol FormLine: UIViewController {
	var actionDelegate: ActionDelegate? { get set }
}
