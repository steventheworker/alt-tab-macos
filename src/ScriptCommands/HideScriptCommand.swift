// call hideUI()
import Foundation
import Cocoa

class HideScriptCommand: NSScriptCommand {
	override func performDefaultImplementation() -> Any? {
        App.app.hideUi()
        DockAltTabMode = false;
        DockAltTabRightDock = false;
        return self
	}
}
