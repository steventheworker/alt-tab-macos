import Foundation
import Cocoa

class appSettingScriptCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        let named = self.evaluatedArguments!["named"] as! String
        let shortcutIndex = (Preferences.appsToShow[0] == .active) ? 0 : Preferences.appsToShow.count - 1 // if shortcut 1 = active, use it, else use last shortcut
        var val = ""
        if (named == "appsToShow") {val = Preferences.appsToShow[shortcutIndex].rawValue}
        else if (named == "showHiddenWindows") {val = Preferences.showHiddenWindows[shortcutIndex].rawValue}
        else if (named == "showFullscreenWindows") {val = Preferences.showFullscreenWindows[shortcutIndex].rawValue}
        else if (named == "showMinimizedWindows") {val = Preferences.showMinimizedWindows[shortcutIndex].rawValue}
        else if (named == "spacesToShow") {val = Preferences.spacesToShow[shortcutIndex].rawValue}
        else if (named == "screensToShow") {val = Preferences.screensToShow[shortcutIndex].rawValue}
        else if (named == "showTabsAsWindows") {val = Preferences.showTabsAsWindows ? "1" : "0"}
        return val
    }
}
