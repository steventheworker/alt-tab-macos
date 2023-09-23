// used by DockAltTab... there doesn't seem to be any other method to count windows (in the current space) THAT ARE HIDDEN (...without tracking a lot of the same events as AltTab already does + caching the results)
import Foundation
import Cocoa

class deminimizeFirstMinimizedWindowFromCurrentSpaceScriptCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        let tarBID = self.evaluatedArguments!["appBID"] as! String
        if (tarBID.trimmingCharacters(in: .whitespacesAndNewlines) == "") { // validate tarBID
            print("tarBID is blank")
            return 0
        }
        let appInstances = NSRunningApplication.runningApplications(withBundleIdentifier: tarBID)
        if appInstances.count == 0 {
            print("tarBID '" + tarBID + "' not running")
            return 0
        }
        let tarApp = appInstances[0]
        var winCount = 0
        // follow countMinimizedWindowsScriptCommand (follows refreshWhichWindowsToShowTheUser (changed from .forEach to for in --to exit the loop early))
        for window:Window in Windows.list {
            if (
//                !(window.application.runningApplication.bundleIdentifier.flatMap { id in Preferences.dontShowBlacklist.contains { id.hasPrefix($0) } } ?? false) &&
                !(/* Preferences.appsToShow[App.app.shortcutIndex] == .active && */ window.application.runningApplication.processIdentifier != tarApp.processIdentifier) && // -and change line: (active app) pid ==> (target app) pid
//                    && ((!Preferences.hideWindowlessApps && window.isWindowlessApp) ||
                    
//                    !window.isWindowlessApp &&
                    /*!(Preferences.spacesToShow[App.app.shortcutIndex] == .visible && !*/Spaces.visibleSpaces.contains(window.spaceId) /*)&&*/
//                    (Preferences.showTabsAsWindows || !window.isTabbed))
                && window.isMinimized
            ) {
                window.minDemin()
                break
            }
        }
        return self
    }
}
