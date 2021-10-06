import UIKit
import PDFKit
import CoreGraphics

/// From Stackoverflow Answer: https://stackoverflow.com/a/56652373
/// By User Michał Kwiecień https://stackoverflow.com/users/1189244/micha%c5%82-kwiecie%c5%84
extension UIImage {
	func fromPDF(data: Data) -> UIImage? {
		guard
			let pdf = PDFDocument(data: data),
			let pdfPage = pdf.page(at: 0),
			let pageRef = pdfPage.pageRef
		else {
			return nil
		}

		let pageRect = pageRef.getBoxRect(.mediaBox)
		let renderer = UIGraphicsImageRenderer(size: pageRect.size)
		let img = renderer.image { ctx in
			UIColor.clear.set()
			ctx.fill(pageRect)

			ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
			ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

			ctx.cgContext.drawPDFPage(pageRef)
		}

		return img
	}
}


extension UIImageView {
	func load(url: URL) {
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			if let data = try? Data(contentsOf: url) {
				if let image = UIImage().fromPDF(data: data) {
					DispatchQueue.main.async {
						self?.image = image
					}
				}
			}
		}
	}
}
