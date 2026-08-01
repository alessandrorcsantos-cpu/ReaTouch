import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var touchBarController: TouchBarController?
    private var reaperController: ReaperController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let reaper = ReaperController()
        let launcher = ApplicationLauncher(appleScriptManager: AppleScriptManager())
        let touchBar = TouchBarController(reaperController: reaper, applicationLauncher: launcher)
        reaper.delegate = touchBar

        reaperController = reaper
        touchBarController = touchBar
        menuBarController = MenuBarController(touchBarController: touchBar, reaperController: reaper)
        reaper.startMonitoring()
        touchBar.presentHome()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}
