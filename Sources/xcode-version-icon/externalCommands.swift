import Foundation

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
