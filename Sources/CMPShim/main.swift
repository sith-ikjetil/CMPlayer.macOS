import AppKit

guard let resourceURL = Bundle.main.url(
    forResource: "cmplayer",
    withExtension: "command"
) else {
    NSLog("cmplayer.command not found")
    exit(1)
}

NSWorkspace.shared.open(resourceURL)
