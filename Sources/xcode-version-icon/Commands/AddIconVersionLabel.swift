import AppKit
import ArgumentParser

struct AddIconVersionLabel: ParsableCommand {

    @OptionGroup
    private var commonArguments: CommonArguments

    @Option(help: "The name of the font to use to render the version number.")
    private var font = NSFont.systemFont(ofSize: 10).fontName

    @Option(help: "The font size to use to render the version number.")
    private var fontSize: CGFloat = 22

    @Flag(help: "Open the icon after modification.")
    private var open: Bool = false

    private lazy var plistPath = "\(commonArguments.xcodePath)/Contents/version.plist"

    private lazy var iconPath = "\(commonArguments.xcodePath)/Contents/Resources/Xcode.icns"

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
