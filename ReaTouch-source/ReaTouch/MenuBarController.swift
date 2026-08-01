import AppKit

final class MenuBarController: NSObject {
    private let statusItem: NSStatusItem
    private let touchBarController: TouchBarController
    private let reaperController: ReaperController

    init(touchBarController: TouchBarController, reaperController: ReaperController) {
        self.touchBarController = touchBarController
        self.reaperController = reaperController
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "slider.horizontal.3", accessibilityDescription: "ReaTouch")
            button.toolTip = "ReaTouch"
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Mostrar Touch Bar", action: #selector(showTouchBar), keyEquivalent: "")
        menu.addItem(withTitle: "Atualizar projetos REAPER", action: #selector(refreshProjects), keyEquivalent: "r")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Encerrar ReaTouch", action: #selector(quit), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
    }

    @objc private func showTouchBar() {
        NSApp.activate(ignoringOtherApps: true)
        touchBarController.presentHome()
    }

    @objc private func refreshProjects() { reaperController.refresh() }
    @objc private func quit() { NSApp.terminate(nil) }
}
