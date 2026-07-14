import AppKit
import ArgumentParser
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreText

enum CorrectionLevel: String, ExpressibleByArgument, CaseIterable {
    case L, M, Q, H
}

func generateQRCode(from string: String, correctionLevel: CorrectionLevel?) -> CIImage? {
    let filter = CIFilter.qrCodeGenerator()

    filter.message = Data(string.utf8)
    filter.correctionLevel = correctionLevel?.rawValue ?? "M"

    return filter.outputImage
}

func createScaledImageForClipboard(from ciImage: CIImage, maxDimension: CGFloat = 400, title: String? = nil, context: CIContext = CIContext()) -> CGImage? {
    let originalWidth = ciImage.extent.width
    let originalHeight = ciImage.extent.height
    let maxOriginalDimension = max(originalWidth, originalHeight)

    let scale: CGFloat = if maxOriginalDimension * 10.0 > maxDimension {
        maxDimension / maxOriginalDimension
    } else {
        10.0
    }

    let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    guard let qrCGImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
        return nil
    }

    guard let title else {
        return qrCGImage
    }

    let qrWidth = qrCGImage.width
    let qrHeight = qrCGImage.height
    let backingScale = NSScreen.main?.backingScaleFactor ?? 2.0
    let fontSize = max(CGFloat(qrWidth) / 20.0, 14.0)
    let titleHeight = fontSize * 2.5
    let totalHeight = CGFloat(qrHeight) + titleHeight

    let scaledWidth = Int(CGFloat(qrWidth) * backingScale)
    let scaledTotalHeight = Int(totalHeight * backingScale)

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let bitmapContext = CGContext(
        data: nil,
        width: scaledWidth,
        height: scaledTotalHeight,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
    ) else {
        return qrCGImage
    }

    bitmapContext.scaleBy(x: backingScale, y: backingScale)

    bitmapContext.setFillColor(NSColor.white.cgColor)
    bitmapContext.fill(CGRect(x: 0, y: 0, width: CGFloat(qrWidth), height: totalHeight))

    bitmapContext.draw(qrCGImage, in: CGRect(x: 0, y: 0, width: qrWidth, height: qrHeight))

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center

    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .bold),
        .foregroundColor: NSColor.black,
        .paragraphStyle: paragraphStyle,
    ]

    let attrString = NSAttributedString(string: title, attributes: attributes)
    let line = CTLineCreateWithAttributedString(attrString)
    let lineWidth = CTLineGetTypographicBounds(line, nil, nil, nil)
    let x = (CGFloat(qrWidth) - lineWidth) / 2
    let y = CGFloat(qrHeight) + (titleHeight - fontSize) / 2

    bitmapContext.textPosition = CGPoint(x: x, y: y)
    CTLineDraw(line, bitmapContext)

    return bitmapContext.makeImage() ?? qrCGImage
}

func copyToPasteboard(_ cgImage: CGImage) {
    let image = NSImage(cgImage: cgImage, size: .zero)

    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.writeObjects([image])
}

func printQRCode(_ ciImage: CIImage) {
    let width = Int(ciImage.extent.width)
    let height = Int(ciImage.extent.height)

    var pixels = [UInt8](repeating: 0, count: width * height)

    guard let context = CGContext(
        data: &pixels,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width,
        space: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGImageAlphaInfo.none.rawValue,
    ) else {
        return
    }

    let ciContext = CIContext()

    guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
        return
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    for y in 0 ..< height {
        var chars: [String] = []
        chars.reserveCapacity(width * 2)

        for x in 0 ..< width {
            let value = pixels[y * width + x]
            chars.append(value < 128 ? "██" : "  ")
        }

        print(chars.joined())
    }
}
