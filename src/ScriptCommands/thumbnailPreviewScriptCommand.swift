import Foundation
import Cocoa

var DockAltTabThumbnailPreview: Bool? = false //cached value, to restore after we force preview
class thumbnailPreviewScriptCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        if (!App.app.appIsBeingUsed) {return self}
        if (DockAltTabThumbnailPreview == nil) {
            DockAltTabThumbnailPreview = CachedUserDefaults.cache["previewFocusedWindow"] as? Bool
            CachedUserDefaults.cache["previewFocusedWindow"] = true
        }
        Windows.previewSelectedWindowIfNeeded()
        //run CachedUserDefaults.cache["previewFocusedWindow"] = UserDefaults.standard.bool(forKey: "previewFocusedWindow")     //on hideui
        return self
    }
}
