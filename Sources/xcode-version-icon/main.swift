import AppKit
import ArgumentParser

// TODO: add flag to also rename app with version
struct XcodeVersionIcon: ParsableCommand {

    @Argument(help: "Path to the Xcode app bundle to modify.")
    private var xcodePath: String

    @Option(help: "The name of the font to use to render the version number.")
    private var font = NSFont.systemFont(ofSize: 10).fontName

    @Option(help: "The font size to use to render the version number.")
    private var fontSize: CGFloat = 22

    @Flag(help: "Open the icon after modification.")
    private var open: Bool = false

    private lazy var plistPath = "\(xcodePath)/Contents/version.plist"

    private lazy var iconPath = "\(xcodePath)/Contents/Resources/Xcode.icns"

    private lazy var tempIconSetPath = FileManager.default.temporaryDirectory.path + NSUUID().uuidString + ".iconset"

    mutating func run() throws {
        convertIcnsToIconset(inPath: iconPath, outPath: tempIconSetPath)

        guard let nsFont = NSFont(name: font, size: fontSize) else {
            print("Cannot load a font named '\(font)' ")
            throw ExitCode.failure
        }

        let version = try xcodeVersion(pListPath: plistPath)
        print("Xcode \(version)")

        try addVersionTag(for: version, toIconSetAt: tempIconSetPath, font: nsFont)

        convertIconsetToIcns(inPath: tempIconSetPath, outPath: iconPath)

        if open {
            openCommand(path: iconPath)
        }
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

func openCommand(path: String) {
    let task = Process()
    task.launchPath = "/usr/bin/open"
    task.arguments = [path]
    task.launch()
    task.waitUntilExit()
}

func xcodeVersion(pListPath: String) throws -> String {
    let pList = try readPlist(at: pListPath)
    guard let version = pList["CFBundleShortVersionString"] as? String else {
        throw ExitCode.failure
    }
    return version
}

func readPlist(at path: String) throws -> [String: Any] {
    var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
    guard let plistXML = FileManager.default.contents(atPath: path) else {
        throw ExitCode.failure
    }
    return try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String: Any]
}

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
