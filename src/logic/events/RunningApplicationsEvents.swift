import Cocoa

class RunningApplicationsEvents {
    private static var appsObserver: NSKeyValueObservation!
    private static var previousValueOfRunningApps: Set<NSRunningApplication>!

    static func observe() {
        previousValueOfRunningApps = Set(NSWorkspace.shared.runningApplications)
        appsObserver = NSWorkspace.shared.observe(\.runningApplications, options: [.old, .new], changeHandler: handleEvent)
        
//        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
//            for i in 0..<18 { print("") }
//            let x = Windows.list.enumerated().map({ (i, w) in
//                return [i+1, w.cgWindowId ?? 0,
//                        w.application.localizedName != nil ? w.application.localizedName! : "",
//                        w.title != nil ? w.title! : "",
//                        w.isTabbed,
//                        w.referenceWindowForTabbedWindow() ?? 0,
//                        w.position ?? 0,
//                        w.size ?? 0,
//                        w.spaceIndexes,
//                        w.spaceIds,
//                        w.dockLabel != nil ? w.dockLabel! : "",
//                        w.isAppMainWindow(),
//                        w.isMinimized,
//                        w.isHidden,
//                        w.isFullscreen,
//                        w.isOnAllSpaces,
//                        w.lastFocusOrder,
//                        w.creationOrder,
//                        w.shouldShowTheUser,
//                        w.canBeClosed(),
//                        w.canBeMinDeminOrFullscreened()]
//            });
//            x.forEach { print($0) }
//        }
//        RunLoop.main.add(timer, forMode: .common)
    }

    // TODO: handle this on a separate thread?
    @Sendable
    private static func handleEvent<A>(_: NSWorkspace, _ change: NSKeyValueObservedChange<A>) {
        let workspaceApps = Set(NSWorkspace.shared.runningApplications)
        // TODO: symmetricDifference has bad performance
        let diff = Array(workspaceApps.symmetricDifference(previousValueOfRunningApps))
        Logger.debug(diff.map { ($0.processIdentifier, $0.bundleIdentifier ?? "nil") })
        if change.kind == .insertion {
            Applications.addRunningApplications(diff)
        } else if change.kind == .removal {
            Applications.removeRunningApplications(diff)
        }
        previousValueOfRunningApps = workspaceApps
    }
}
