/**
 The `BundleLocatorProtocol` code is taken from the Stripe iOS SDK (https://github.com/stripe/stripe-ios)
 and is licensed under the MIT license, which is attached here:
 
 The MIT License

 Copyright (c) 2011- Stripe, Inc. (https://stripe.com)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation

extension Foundation.Bundle {
	static var current: Bundle = {
		return XS2AiOSBundleLocator.resourcesBundle
	}()
	static var images: Bundle = {
		return XS2AiOSImageBundleLocator.resourcesBundle
	}()
}

final class XS2AiOSImageBundleLocator: BundleLocatorProtocol {
	static let internalClass: AnyClass = XS2AiOSImageBundleLocator.self
	static let bundleName = "Images"
	#if SWIFT_PACKAGE
	static let spmResourcesBundle = Bundle.module
	#endif
	static let resourcesBundle = XS2AiOSImageBundleLocator.computeResourcesBundle()
}

final class XS2AiOSBundleLocator: BundleLocatorProtocol {
	static let internalClass: AnyClass = XS2AiOSBundleLocator.self
	static let bundleName = "XS2AiOS"
	#if SWIFT_PACKAGE
	static let spmResourcesBundle = Bundle.module
	#endif
	static let resourcesBundle = XS2AiOSBundleLocator.computeResourcesBundle()
}

public protocol BundleLocatorProtocol {
	/**
	 A final class that is internal to the bundle implementing this protocol.
	 
	 - Note: The class must be `final` to ensure that it can't be subclassed,
	 which may change the result of `bundleForClass`.
	 */
	static var internalClass: AnyClass { get }

	/// Name of the bundle.
	static var bundleName: String { get }

	/// Cached result from `computeResourcesBundle()` so it doesn't need to be recomputed.
	static var resourcesBundle: Bundle { get }
	
	#if SWIFT_PACKAGE
	/// SPM Bundle, if available. Implementation should be should be `Bundle.module`.
	static var spmResourcesBundle: Bundle { get }
	#endif
}

public extension BundleLocatorProtocol {
	/**
	 Computes the bundle to fetch resources from.
	 - Note: This should never be called directly. Instead, call `resourcesBundle`.
	 - Description:
	 Places to check:
	 1. Swift Package Manager bundle
	 2. XS2AiOS.bundle (for manual static installations and framework-less Cocoapods)
	 3. XS2AiOS.framework/XS2AiOS.bundle (for framework-based Cocoapods)
	 4. XS2AiOS.framework (for Carthage, manual dynamic installations)
	 5. main bundle (for people dragging all our files into their project)
	 */
	static func computeResourcesBundle() -> Bundle {
		var ourBundle: Bundle?
		
		#if SWIFT_PACKAGE
		ourBundle = spmResourcesBundle
		#endif

		if ourBundle == nil {
			ourBundle = Bundle(path: "\(bundleName).bundle")
		}

		if ourBundle == nil {
			// This might be the same as the previous check if not using a dynamic framework
			if let path = Bundle(for: internalClass).path(
				forResource: bundleName, ofType: "bundle")
			{
				ourBundle = Bundle(path: path)
			}
		}

		if ourBundle == nil {
			// This will be the same as mainBundle if not using a dynamic framework
			ourBundle = Bundle(for: internalClass)
		}

		if let ourBundle = ourBundle {
			return ourBundle
		} else {
			return Bundle.main
		}
	}
}
