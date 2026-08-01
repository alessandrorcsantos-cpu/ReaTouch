import Foundation

final class AppleScriptManager {
    func activate(applicationNamed name: String) {
        let escaped = name.replacingOccurrences(of: "\"", with: "\\\"")
        NSAppleScript(source: "tell application \\\"\(escaped)\\\" to activate")?.executeAndReturnError(nil)
    }
}
