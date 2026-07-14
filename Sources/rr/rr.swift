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
