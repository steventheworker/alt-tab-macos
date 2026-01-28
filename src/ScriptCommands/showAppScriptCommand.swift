var DockAltTabFORCEDX = 0
var DockAltTabFORCEDY = 0
var DockAltTabMode = false
var DockAltTabDockPos = ""
var DockAltTabApp: NSRunningApplication? = nil

func DockAltTabRadiusFix() {
    if (Preferences.theme != .macOs) {return}
    let num = 22.0
    App.app.thumbnailsPanel.thumbnailsView.contentView.layer?.cornerRadius = CGFloat(num)
    App.app.thumbnailsPanel.thumbnailsView.contentView.updateRoundedCorners(num)
    App.app.thumbnailsPanel.thumbnailsView.scrollView.layer?.cornerRadius = CGFloat(num)
}
func startDockAltTabMode(app: NSRunningApplication) {
    DockAltTabMode = true
    DockAltTabRadiusFix()
    DockAltTabApp = app
}
func DockAltTabResetCachedThumbnailPreviewSetting() {
    if (DockAltTabThumbnailPreview != nil) {
        CachedUserDefaults.cache["previewFocusedWindow"] = DockAltTabThumbnailPreview
        DockAltTabThumbnailPreview = nil
    }
}
func DockAltTabReset() { //called on HideScriptCommand.swift, App.showUiOrCycleSelection (key shortcut)
    DockAltTabMode = false
    DockAltTabRadiusFix()
    DockAltTabFORCEDX = 0
    DockAltTabFORCEDY = 0
    DockAltTabResetCachedThumbnailPreviewSetting()
}

// used by DockAltTab - show window previews for a specific app (1st window highlighted), ignoring blacklist
import Foundation
import Cocoa

class showAppScriptCommand: NSScriptCommand {
	override func performDefaultImplementation() -> Any? {
        DockAltTabResetCachedThumbnailPreviewSetting()
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
            startDockAltTabMode(app: appInstances.first!)
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
        
        /*
         begin follow/modify showUIOrCycleSelection
         */
        if App.app.isFirstSummon {
            NSScreen.updatePreferred()
            if App.app.isVeryFirstSummon {
                Windows.sortByLevel()
                App.app.isVeryFirstSummon = false
            }
            App.app.isFirstSummon = false
            App.app.shortcutIndex = 2 // Shortcut 3 = index 2 = DockAltTab
            if !Windows.updatesBeforeShowing() { App.app.hideUi(); return self }
            //            Windows.detectTabbedWindows()
            //            Spaces.refreshAllIdsAndIndexes()
            //            Windows.updateSpaces()
            Windows.list.forEach { (window: Window) in // follow refreshWhichWindowsToShowTheUser
                var inVisibleSpace = false
                window.spaceIds.forEach { spaceId in
                    if Spaces.visibleSpaces.contains(spaceId) {inVisibleSpace = true}
                }
                window.shouldShowTheUser =
//                    !(window.application.bundleIdentifier.flatMap { id in
//                        Preferences.blacklist.contains {
//                            id.hasPrefix($0.bundleIdentifier) &&
//                                ($0.hide == .always || (window.isWindowlessApp && $0.hide != .none))
//                        }
//                    } ?? false) &&
                    !(/* Preferences.appsToShow[App.app.shortcutIndex] == .active && */ window.application.pid != tarApp.processIdentifier) &&
//                    !(Preferences.appsToShow[App.app.shortcutIndex] == .nonActive && window.application.pid == tarApp.processIdentifier) &&
                    !(!(Preferences.showHiddenWindows[App.app.shortcutIndex] != .hide) && window.isHidden) &&
                    ((Preferences.showWindowlessApps[App.app.shortcutIndex] != .hide && window.isWindowlessApp) ||
                        !window.isWindowlessApp &&
                        !(!(Preferences.showFullscreenWindows[App.app.shortcutIndex] != .hide) && window.isFullscreen) &&
                        !(!(Preferences.showMinimizedWindows[App.app.shortcutIndex] != .hide) && window.isMinimized) &&
                        !(Preferences.spacesToShow[App.app.shortcutIndex] == .visible && !inVisibleSpace) &&
                        !(Preferences.screensToShow[App.app.shortcutIndex] == .showingAltTab && !window.isOnScreen(NSScreen.preferred)) &&
                        (Preferences.showTabsAsWindows || !window.isTabbed))
            }
            //            Windows.reorderList()
            Windows.setInitialSelectedAndHoveredWindowIndex()
            if Preferences.windowDisplayDelay == DispatchTimeInterval.milliseconds(0) {
                App.app.buildUiAndShowPanel()
            } else {
                App.app.delayedDisplayScheduled += 1
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Preferences.windowDisplayDelay) { () -> () in
                    if App.app.delayedDisplayScheduled == 1 {
                        App.app.buildUiAndShowPanel()
                    }
                    App.app.delayedDisplayScheduled -= 1
                }
            }
        } else {
            App.app.cycleSelection(.leading)
            KeyRepeatTimer.startRepeatingKeyNextWindow()
        } // stop following showUIOrCycleSelection
        
        // make sure focus is on 1st window
//        if (DockAltTabMode && DockAltTabDockPos == "right") {App.app.previousWindowShortcutWithRepeatingKey()}
//        if (DockAltTabMode && DockAltTabDockPos == "right") {App.app.previousWindowShortcutWithRepeatingKey()}
        
        //follow hideUI
//        App.app.appIsBeingUsed = false
//        App.app.isFirstSummon = true
//        MouseEvents.toggle(false)
//        App.app.hideThumbnailPanelWithoutChangingKeyWindow()
        
        
        //todo: if DAT mode && mouse hovered on preview:
            //turn "previews selected window" on ——after x milliseconds hovered over
        //todo: if DAT mode:  always use "select windows on mouse hover" (must be 'selected' for preview to work)
        return self
	}
}
