import Foundation
import ArgumentParser

struct RestoreIcon: ParsableCommand {
    @OptionGroup
    private var commonArguments: CommonArguments

    func run() throws {
        let fileManager = FileManager.default
        let backupPath = commonArguments.iconPath + XcodeVersionIcon.backupExtension
        let iconPath = commonArguments.iconPath

        guard fileManager.fileExists(atPath: backupPath) else {
            throw ExitCode.failure
        }

        try fileManager.removeItem(atPath: iconPath)
        try fileManager.copyItem(
            atPath: backupPath,
            toPath: iconPath)
        try fileManager.removeItem(atPath: backupPath)
    }
}
