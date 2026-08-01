import Foundation

struct ReaperProject: Equatable {
    let id: String
    let displayName: String
    let path: String
}

protocol ReaperControllerDelegate: AnyObject { func reaperProjectsDidChange() }

final class ReaperController {
    weak var delegate: ReaperControllerDelegate?
    private(set) var projects: [ReaperProject] = []
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.reatouch.reaper")
    private var timer: DispatchSourceTimer?

    private var supportDirectory: URL {
        fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/ReaTouch", isDirectory: true)
    }
    private var projectFile: URL { supportDirectory.appendingPathComponent("open_projects.tsv") }
    private var commandFile: URL { supportDirectory.appendingPathComponent("command.txt") }

    func startMonitoring() {
        try? fileManager.createDirectory(at: supportDirectory, withIntermediateDirectories: true)
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(300))
        timer.setEventHandler { [weak self] in self?.loadProjects() }
        timer.resume()
        self.timer = timer
    }

    func refresh() { queue.async { [weak self] in self?.loadProjects(force: true) } }

    func select(_ project: ReaperProject) {
        queue.async { [weak self] in
            guard let self else { return }
            let command = "SELECT\\t\(project.id)\\n"
            try? command.write(to: self.commandFile, atomically: true, encoding: .utf8)
        }
    }

    private func loadProjects(force: Bool = false) {
        guard let text = try? String(contentsOf: projectFile, encoding: .utf8) else { return }
        let loaded = text.split(separator: "\\n").compactMap { line -> ReaperProject? in
            let columns = line.split(separator: "\\t", maxSplits: 2, omittingEmptySubsequences: false).map(String.init)
            guard columns.count == 3 else { return nil }
            return ReaperProject(id: columns[0], displayName: columns[1], path: columns[2])
        }
        guard force || loaded != projects else { return }
        projects = loaded
        DispatchQueue.main.async { [weak self] in self?.delegate?.reaperProjectsDidChange() }
    }
}
