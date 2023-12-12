//
//  UIImage+Extensions.swift
//  SwiftUIAsyncPhotoExample
//
//  Created by Toomas Vahter on 09.12.2023.
//

import UIKit

extension UIImage {
    static func filled(size: CGSize, fillColor: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            fillColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension UIImage {
    public func scaled(toFill targetSize: CGSize) async -> UIImage {
        let scaler = UIGraphicsImageRenderer(size: targetSize)
        let finalImage = scaler.image { context in
            let drawRect = size.drawRect(toFill: targetSize)
            draw(in: drawRect)
        }
        return await finalImage.byPreparingForDisplay() ?? finalImage
    }
}

private extension CGSize {
    func drawRect(toFill targetSize: CGSize) -> CGRect {
        let aspectWidth = targetSize.width / width
        let aspectHeight = targetSize.height / height
        let scale = max(aspectWidth, aspectHeight)
        let drawRect = CGRect(x: (targetSize.width - width * scale) / 2.0,
                              y: (targetSize.height - height * scale) / 2.0,
                              width: width * scale,
                              height: height * scale)
        return drawRect.integral
    }
}
