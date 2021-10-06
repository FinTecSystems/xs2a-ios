import UIKit

/// Protocol for all FormLine Elements
protocol FormLine: UIViewController {
	var actionDelegate: ActionDelegate? { get set }
	var multiFormName: String? { get }
	var multiFormValue: String? { get }
}
