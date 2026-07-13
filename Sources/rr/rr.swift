import AppKit
import ArgumentParser
import CoreImage
import CoreImage.CIFilterBuiltins

@main
struct RR: ParsableCommand {
    @Option(name: .shortAndLong, help: "QR Code error correction level (L, M, Q, or H).")
    var level: String? = nil

    @Argument(help: "Text to encode into the QR code.")
    var text: String

    @Flag(name: .shortAndLong, help: "Copy the QR code image to the clipboard.")
    var copy = false

    mutating func run() throws {
        guard let ciImage = generateQRCode(from: text, correctionLevel: level),
              let cgImage = createScaledImage(from: ciImage, scale: 10.0)
        else {
            throw ValidationError("Failed to generate QR code.")
        }

        printQRCode(ciImage)

        if copy {
            copyToPastedboard(cgImage)
            print("Copied your clipboard!")
        }
    }
}

func generateQRCode(from string: String, correctionLevel: String?) -> CIImage? {
    let filter = CIFilter.qrCodeGenerator()

    filter.message = Data(string.utf8)
    filter.correctionLevel = correctionLevel ?? "M"

    return filter.outputImage
}

func createScaledImage(from ciImage: CIImage, scale: CGFloat, context: CIContext = CIContext()) -> CGImage? {
    let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

    return context.createCGImage(scaledImage, from: scaledImage.extent)
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
