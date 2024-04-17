var DockAltTabFORCEDX = 0;
var DockAltTabFORCEDY = 0;
var DockAltTabMode = false;
var DockAltTabDockPos = "";

func DockAltTabRadiusFix() {App.app.thumbnailsPanel.thumbnailsView.updateRoundedCorners(DockAltTabMode ? 15 : Preferences.windowCornerRadius)} //line found in App.resetPreferencesDependentComponents
func startDockAltTabMode() {
    DockAltTabMode = true
    DockAltTabRadiusFix()
}
func DockAltTabReset() { //called on HideScriptCommand.swift, App.showUiOrCycleSelection (key shortcut)
    DockAltTabMode = false
    DockAltTabRadiusFix()
    DockAltTabFORCEDX = 0
    DockAltTabFORCEDY = 0
}

// used by DockAltTab - show window previews for a specific app (1st window highlighted), ignoring blacklist
import Foundation
import Cocoa

class showAppScriptCommand: NSScriptCommand {
	override func performDefaultImplementation() -> Any? {
        let tarBID = self.evaluatedArguments!["appBID"] as! String
        if (tarBID.trimmingCharacters(in: .whitespacesAndNewlines) == "") { // validate tarBID
            print("tarBID is blank")
            return self
        }
        let appInstances = NSRunningApplication.runningApplications(withBundleIdentifier: tarBID)
        if appInstances.count == 0 {
            print("tarBID '" + tarBID + "' not running")
            return self
        }
        if (self.evaluatedArguments!["x"] != nil || self.evaluatedArguments!["y"] != nil) {
            startDockAltTabMode()
        } else {DockAltTabReset()/*DockAltTabMode = false*/}
        var x = 0, y = 0
        if (self.evaluatedArguments!["x"] == nil) {
            x = Int(NSEvent.mouseLocation.x) - 40
        } else {x = self.evaluatedArguments!["x"] as! Int}
        if (self.evaluatedArguments!["y"] == nil) {
            y = Int(NSEvent.mouseLocation.y) + 40 //assume bottom dock w/ max icon size 100px
        } else {y = self.evaluatedArguments!["y"] as! Int}
        DockAltTabFORCEDX = x
        DockAltTabFORCEDY = y
        DockAltTabDockPos = self.evaluatedArguments!["dockPos"] == nil ? "bottom" : self.evaluatedArguments!["dockPos"] as! String;
        let tarApp = appInstances[0]
        App.app.appIsBeingUsed = true /* actually line 1 of showUI() */
        if App.app.isFirstSummon { // begin follow/modify showUIOrCycleSelection
            debugPrint("showUiOrCycleSelection: isFirstSummon")
            App.app.isFirstSummon = false
            if Windows.list.count == 0 || MissionControl.isActive() { App.app.hideUi(); return self }
//            Windows.detectTabbedWindows()
            Spaces.refreshAllIdsAndIndexes()
            Windows.updateSpaces()
            let screen = NSScreen.preferred()
            (Preferences.appsToShow[0] == .active) ? (App.app.shortcutIndex = 0) : (App.app.shortcutIndex = Preferences.appsToShow.count - 1) // if shortcut 1 = active, use it, else use last shortcut
            Windows.list.forEach { (window: Window) in // follow refreshWhichWindowsToShowTheUser
                window.shouldShowTheUser =
//                    !(window.application.runningApplication.bundleIdentifier.flatMap { id in Preferences.dontShowBlacklist.contains { id.hasPrefix($0) } } ?? false) &&
                    !(/* Preferences.appsToShow[App.app.shortcutIndex] == .active && */ window.application.runningApplication.processIdentifier != tarApp.processIdentifier) && // -and change line: (active app) pid ==> (target app) pid
                    !(!(Preferences.showHiddenWindows[App.app.shortcutIndex] != .hide) && window.isHidden) &&
                    ((!Preferences.hideWindowlessApps && window.isWindowlessApp) ||
                        !window.isWindowlessApp &&
                        !(!(Preferences.showFullscreenWindows[App.app.shortcutIndex] != .hide) && window.isFullscreen) &&
                        !(!(Preferences.showMinimizedWindows[App.app.shortcutIndex] != .hide) && window.isMinimized) &&
                        !(Preferences.spacesToShow[App.app.shortcutIndex] == .visible && !Spaces.visibleSpaces.contains(window.spaceId)) &&
                        !(Preferences.screensToShow[App.app.shortcutIndex] == .showingAltTab && !window.isOnScreen(screen)) &&
                        (Preferences.showTabsAsWindows || !window.isTabbed))
            }
            Windows.reorderList()
            if (!Windows.list.contains { $0.shouldShowTheUser }) { App.app.hideUi(); return self }
            Windows.setInitialFocusedAndHoveredWindowIndex()
            App.app.delayedDisplayScheduled += 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Preferences.windowDisplayDelay) { () -> () in
                if App.app.delayedDisplayScheduled == 1 {
                    App.app.rebuildUi(screen)
                }
                App.app.delayedDisplayScheduled -= 1
            }
        } else {
            App.app.cycleSelection(.leading)
            KeyRepeatTimer.toggleRepeatingKeyNextWindow()
        } // stop following showUIOrCycleSelection
        
        // make sure focus is on 1st window
         if (DockAltTabMode && DockAltTabDockPos == "right") {App.app.previousWindowShortcutWithRepeatingKey()}
//        if (DockAltTabMode && DockAltTabDockPos == "right") {App.app.previousWindowShortcutWithRepeatingKey()}
        
        //follow hideUI
//        App.app.appIsBeingUsed = false
//        App.app.isFirstSummon = true
//        MouseEvents.toggle(false)
//        App.app.hideThumbnailPanelWithoutChangingKeyWindow()
        return self
	}
}
