import AppKit

enum ManagedApplication { case reaper, kontakt, keyscape, chrome, anyDesk }

final class ApplicationLauncher {
    private let appleScriptManager: AppleScriptManager
    init(appleScriptManager: AppleScriptManager) { self.appleScriptManager = appleScriptManager }

    func launch(_ app: ManagedApplication) {
        let descriptor: (bundleID: String, name: String, paths: [String])
        switch app {
        case .reaper: descriptor = ("com.cockos.reaper", "REAPER", ["/Applications/REAPER.app"])
        case .kontakt: descriptor = ("com.native-instruments.Kontakt 7", "Kontakt 7", ["/Applications/Native Instruments/Kontakt 7.app", "/Applications/Kontakt 7.app"])
        case .keyscape: descriptor = ("com.spectrasonics.Keyscape", "Keyscape", ["/Applications/Keyscape.app"])
        case .chrome: descriptor = ("com.google.Chrome", "Google Chrome", ["/Applications/Google Chrome.app"])
        case .anyDesk: descriptor = ("com.philandro.anydesk", "AnyDesk", ["/Applications/AnyDesk.app"])
        }
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: descriptor.bundleID) {
            NSWorkspace.shared.openApplication(at: url, configuration: .init(), completionHandler: nil)
        } else if let path = descriptor.paths.first(where: { FileManager.default.fileExists(atPath: $0) }) {
            NSWorkspace.shared.open(URL(fileURLWithPath: path))
        } else {
            appleScriptManager.activate(applicationNamed: descriptor.name)
        }
    }
}
