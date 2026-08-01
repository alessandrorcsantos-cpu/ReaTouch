import AppKit

final class TouchBarController: NSObject, NSTouchBarDelegate, ReaperControllerDelegate {
    private enum Page { case home, projects }
    private var page: Page = .home
    private let reaperController: ReaperController
    private let applicationLauncher: ApplicationLauncher
    private var activeTouchBar: NSTouchBar?

    init(reaperController: ReaperController, applicationLauncher: ApplicationLauncher) {
        self.reaperController = reaperController
        self.applicationLauncher = applicationLauncher
        super.init()
    }

    func presentHome() { page = .home; rebuildTouchBar() }
    func reaperProjectsDidChange() { if page == .projects { rebuildTouchBar() } }

    private func rebuildTouchBar() {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        switch page {
        case .home:
            touchBar.defaultItemIdentifiers = [.reaper, .kontakt, .keyscape, .chrome, .anydesk]
        case .projects:
            touchBar.defaultItemIdentifiers = [.back] + reaperController.projects.map { Self.identifier(for: $0.id) }
        }
        activeTouchBar = touchBar
        NSApp.touchBar = touchBar
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .reaper: return buttonItem(identifier, title: "REAPER") { [weak self] in self?.openProjects() }
        case .kontakt: return buttonItem(identifier, title: "Kontakt") { [weak self] in self?.applicationLauncher.launch(.kontakt) }
        case .keyscape: return buttonItem(identifier, title: "Keyscape") { [weak self] in self?.applicationLauncher.launch(.keyscape) }
        case .chrome: return buttonItem(identifier, title: "Chrome") { [weak self] in self?.applicationLauncher.launch(.chrome) }
        case .anydesk: return buttonItem(identifier, title: "AnyDesk") { [weak self] in self?.applicationLauncher.launch(.anyDesk) }
        case .back: return buttonItem(identifier, title: "←") { [weak self] in self?.presentHome() }
        default:
            guard page == .projects, let project = reaperController.projects.first(where: { Self.identifier(for: $0.id) == identifier }) else { return nil }
            return buttonItem(identifier, title: project.displayName) { [weak self] in self?.select(project) }
        }
    }

    private func openProjects() { page = .projects; reaperController.refresh(); rebuildTouchBar() }
    private func select(_ project: ReaperProject) { applicationLauncher.launch(.reaper); reaperController.select(project) }

    private func buttonItem(_ identifier: NSTouchBarItem.Identifier, title: String, action: @escaping () -> Void) -> NSTouchBarItem {
        let item = NSCustomTouchBarItem(identifier: identifier)
        let button = ActionButton(title: title, actionHandler: action)
        button.bezelColor = .black
        button.contentTintColor = .white
        button.font = .systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: title == "←" ? 52 : 120).isActive = true
        item.view = button
        return item
    }

    private static func identifier(for projectID: String) -> NSTouchBarItem.Identifier {
        .init("com.reatouch.project." + projectID)
    }
}

private final class ActionButton: NSButton {
    private let actionHandler: () -> Void

    init(title: String, actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
        super.init(frame: .zero)
        self.title = title
        target = self
        action = #selector(invokeHandler)
    }

    required init?(coder: NSCoder) { nil }
    @objc private func invokeHandler() { actionHandler() }
}

private extension NSTouchBarItem.Identifier {
    static let reaper = Self("com.reatouch.reaper")
    static let kontakt = Self("com.reatouch.kontakt")
    static let keyscape = Self("com.reatouch.keyscape")
    static let chrome = Self("com.reatouch.chrome")
    static let anydesk = Self("com.reatouch.anydesk")
    static let back = Self("com.reatouch.back")
}
