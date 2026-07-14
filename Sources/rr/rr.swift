import AppKit
import ArgumentParser
import CoreImage
import CoreImage.CIFilterBuiltins

enum CorrectionLevel: String, ExpressibleByArgument, CaseIterable {
    case L, M, Q, H
}

@main
struct RR: ParsableCommand {
    @Option(name: .shortAndLong, help: "QR Code error correction level (L, M, Q, or H).")
    var level: CorrectionLevel? = nil

    @Argument(help: "Text to encode into the QR code.")
    var text: String

    @Flag(name: .shortAndLong, help: "Copy the QR code image to the clipboard.")
    var copy = false

    @Flag(name: .shortAndLong, help: "Suppress QR code display in terminal.")
    var quiet = false

    @Option(name: .shortAndLong, help: "Max clipboard image dimension in pixels.")
    var size: Int = 400

    @Option(name: .shortAndLong, help: "Title text to overlay on the QR code image.")
    var title: String? = nil

    mutating func run() throws {
        guard let ciImage = generateQRCode(from: text, correctionLevel: level)
        else {
            throw ValidationError("Failed to generate QR code.")
        }

        if !quiet {
            printQRCode(ciImage)
        }

        if copy {
            let cgImage = createScaledImageForClipboard(from: ciImage, maxDimension: CGFloat(size), title: title)
            copyToPastedboard(cgImage)
            print("Copied your clipboard!")
        }
    }
}

func generateQRCode(from string: String, correctionLevel: CorrectionLevel?) -> CIImage? {
    let filter = CIFilter.qrCodeGenerator()

    filter.message = Data(string.utf8)
    filter.correctionLevel = correctionLevel?.rawValue ?? "M"

    return filter.outputImage
}

func createScaledImage(from ciImage: CIImage, scale: CGFloat, context: CIContext = CIContext()) -> CGImage? {
    let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

    return context.createCGImage(scaledImage, from: scaledImage.extent)
}

func createScaledImageForClipboard(from ciImage: CIImage, maxDimension: CGFloat = 400, title: String? = nil, context: CIContext = CIContext()) -> CGImage {
    let originalWidth = ciImage.extent.width
    let originalHeight = ciImage.extent.height
    let maxOriginalDimension = max(originalWidth, originalHeight)

    let scale: CGFloat
    if maxOriginalDimension * 10.0 > maxDimension {
        scale = maxDimension / maxOriginalDimension
    } else {
        scale = 10.0
    }

    let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    let qrCGImage = context.createCGImage(scaledImage, from: scaledImage.extent)!

    guard let title else {
        return qrCGImage
    }

    let qrWidth = qrCGImage.width
    let qrHeight = qrCGImage.height
    let fontSize = max(CGFloat(qrWidth) / 20.0, 14.0)
    let titleHeight = fontSize * 2.5
    let totalHeight = CGFloat(qrHeight) + titleHeight

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let bitmapContext = CGContext(
        data: nil,
        width: qrWidth,
        height: Int(totalHeight),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        return qrCGImage
    }

    bitmapContext.setFillColor(NSColor.white.cgColor)
    bitmapContext.fill(CGRect(x: 0, y: 0, width: qrWidth, height: Int(totalHeight)))

    bitmapContext.draw(qrCGImage, in: CGRect(x: 0, y: 0, width: qrWidth, height: qrHeight))

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center

    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .bold),
        .foregroundColor: NSColor.black,
        .paragraphStyle: paragraphStyle,
        .backgroundColor: NSColor.white,
    ]

    let textRect = CGRect(
        x: 0,
        y: CGFloat(qrHeight),
        width: CGFloat(qrWidth),
        height: titleHeight
    )

    let nsImage = NSImage(cgImage: bitmapContext.makeImage()!, size: NSSize(width: CGFloat(qrWidth), height: totalHeight))
    nsImage.lockFocus()
    (title as NSString).draw(in: textRect, withAttributes: attributes)
    nsImage.unlockFocus()

    guard let tiffData = nsImage.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let finalCGImage = bitmapRep.cgImage
    else {
        return qrCGImage
    }

    return finalCGImage
}

func copyToPastedboard(_ cgImage: CGImage) {
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
        bitmapInfo: CGImageAlphaInfo.none.rawValue
    ) else {
        return
    }

    let ciContext = CIContext()

    guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
        return
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    for y in 0 ..< height {
        var line = ""

        for x in 0 ..< width {
            let value = pixels[y * width + x]
            line += value < 128 ? "██" : "  "
        }

        print(line)
    }
}
