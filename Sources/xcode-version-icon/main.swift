import AppKit
import ArgumentParser

struct XcodeVersionIcon: ParsableCommand {

    @Argument(help: "Path to the Xcode app bundle to modify.")
    private var xcodePath: String

    @Option(help: "The name of the font to use to render the version number.")
    private var font = ""

    @Option(help: "The font size to use to render the version number.")
    private var fontSize = ""

    private lazy var iconPath = "\(xcodePath)/Contents/Resources/Xcode.icns"

    private lazy var tempIconSetPath = FileManager.default.temporaryDirectory.path + NSUUID().uuidString + ".iconset"

    mutating func run() throws {
        convertIcnsToIconset(inPath: iconPath, outPath: tempIconSetPath)

        try addVersionTag(toIconSetAt: tempIconSetPath)

        convertIconsetToIcns(inPath: tempIconSetPath, outPath: iconPath)
    }
}

XcodeVersionIcon.main()

// MARK: - Functions

func convertIcnsToIconset(inPath: String, outPath: String) {
    iconutil(inPath: inPath, outPath: outPath, options: ["-c", "iconset"])
}

func convertIconsetToIcns(inPath: String, outPath: String) {
    iconutil(inPath: inPath, outPath: outPath, options: ["-c", "icns"])
}

func iconutil(inPath: String, outPath: String, options: [String]) {
    let task = Process()
    task.launchPath = "/usr/bin/iconutil"
    task.arguments = options + ["-o", outPath, inPath]
    task.launch()
    task.waitUntilExit()
}

func addVersionTag(toIconSetAt iconSetPath: String) throws {
    let files = try FileManager.default.contentsOfDirectory(atPath: iconSetPath)
    for filePath in files {
        try addVersionTag(toIconAt: "\(iconSetPath)/\(filePath)")
    }
}

func addVersionTag(toIconAt iconPath: String) throws {
    guard let icon = NSImage(contentsOfFile: iconPath) else { return }
    let modifiedImage = icon.addTextToImage("12.2")
    try modifiedImage.write(to: iconPath)
}

extension NSImage {

    func addTextToImage(_ text: String) -> NSImage {
        let textOrigin = CGPoint(x: self.size.height/3, y: -self.size.width/4)
        return addTextToImage(text, at: textOrigin)
    }

    func addTextToImage(_ text: String, at textOrigin: CGPoint) -> NSImage {

        let targetImage = NSImage(size: self.size, flipped: false) { (dstRect: CGRect) -> Bool in

            self.draw(in: dstRect)
            let textColor = NSColor.white
            let textFont = NSFont(name: "Snell Roundhand", size: 36)! //Helvetica Bold
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center

            let textFontAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: textFont,
                NSAttributedString.Key.foregroundColor: textColor
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
