import AppKit
import ArgumentParser

XcodeVersionIcon.main()

// TODO: add flag to also rename app with version
// TODO: ability to backup and restore original icon
// TODO: Rename to something more generic, this works for any app
// TODO: ability to print app version
struct XcodeVersionIcon: ParsableCommand {

    static let configuration = CommandConfiguration(
        subcommands: [AddIconVersionLabel.self],
        defaultSubcommand: AddIconVersionLabel.self
    )
}

struct CommonArguments: ParsableArguments {
    @Argument(help: "Path to the Xcode app bundle to modify.")
    var xcodePath: String
}
