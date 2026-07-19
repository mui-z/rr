import ArgumentParser
import CoreImage

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

    @Option(name: .shortAndLong, help: "Output file path for the QR code image.", completion: .file(extensions: ["png", "jpg", "jpeg", "tiff", "tif", "bmp", "gif"]))
    var output: String? = nil

    mutating func run() throws {
        guard size > 0 else {
            throw ValidationError("--size must be a positive integer.")
        }

        guard let ciImage = generateQRCode(from: text, correctionLevel: level)
        else {
            throw ValidationError("Failed to generate QR code.")
        }

        if !quiet {
            printQRCode(ciImage)
        }

        if copy {
            guard let cgImage = createScaledImage(from: ciImage, maxDimension: CGFloat(size), title: title) else {
                throw ValidationError("Failed to create clipboard image.")
            }
            copyToPasteboard(cgImage)
            print("Copied to clipboard!")
        }

        if let outputPath = output {
            try saveQRCodeToFile(ciImage, path: outputPath, maxDimension: CGFloat(size), title: title)
            print("Saved to \(outputPath)")
        }
    }
}
