import AppKit
import ArgumentParser

func addVersionTag(for version: String, toIconSetAt iconSetPath: String, font: NSFont) throws {
    let files = try FileManager.default.contentsOfDirectory(atPath: iconSetPath)
    for filePath in files {
        try addVersionTag(for: version, toIconAt: "\(iconSetPath)/\(filePath)", font: font)
    }
}

func addVersionTag(for version: String, toIconAt iconPath: String, font: NSFont) throws {
    guard let icon = NSImage(contentsOfFile: iconPath) else { return }
    let modifiedImage = icon.addTextToImage(version, font: font)
    try modifiedImage.write(to: iconPath)
}

extension NSImage {

    func addTextToImage(_ text: String, font: NSFont) -> NSImage {
        let textOrigin = CGPoint(x: self.size.height/5, y: -self.size.width/6)
        return addTextToImage(text, at: textOrigin, font: font)
    }

    func addTextToImage(_ text: String, at textOrigin: CGPoint, font: NSFont) -> NSImage {

        let targetImage = NSImage(size: self.size, flipped: false) { (dstRect: CGRect) -> Bool in

            self.draw(in: dstRect)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center

            let textFontAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: NSColor.white,
            ]

            let rect = CGRect(origin: textOrigin, size: self.size)
            text.draw(in: rect, withAttributes: textFontAttributes)
            return true
        }
        return targetImage
    }

    func write(to file: String) throws {
        let properties = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
        guard
            let imageData = tiffRepresentation,
            let imageRep = NSBitmapImageRep(data: imageData),
            let fileData = imageRep.representation(using: .png, properties: properties) else {
                return
        }
        try fileData.write(to: URL(fileURLWithPath: file))
    }
}

extension CGFloat: ExpressibleByArgument {
    public init?(argument: String) {
        guard let float = Float(argument: argument) else { return nil }
        self.init(float)
    }
}
