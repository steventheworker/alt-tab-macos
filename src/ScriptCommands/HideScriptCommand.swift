// call hideUI()
import Foundation
import Cocoa

class HideScriptCommand: NSScriptCommand {
	override func performDefaultImplementation() -> Any? {
        App.app.hideUi()
        DockAltTabMode = false
        DockAltTabFORCEDX = 0
        DockAltTabFORCEDY = 0
        return self
	}
}
