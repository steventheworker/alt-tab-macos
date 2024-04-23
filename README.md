## "scriptable" branch of [lwouis/alt-tab-macos](https://alt-tab-macos.netlify.app/)

Made for use with [DockAltTab](https://dockalttab.netlify.app) (adds window previews to the MacOS dock)... it does so by sending AppleScript commands to AltTab.


# [AppleScript Dictionary](https://github.com/steventheworker/alt-tab-macos/blob/scriptable/AltTab.sdef)
- coming soon...

### example usages:
```tell application "AltTab" to showApp appBID "com.apple.Safari"```

```tell application "AltTab" to showApp appBID "com.apple.Safari" x 0 y 0```

```tell application "AltTab" to hide```

# Other Differences
Some other changes I made out of personal preference / hesitation to submit a pull request:
- ignore some app's windows
    - [BetterTouchTool]() "pinned"/floating windows
    - [Screenhint]() floating windows
- Preview button order: Exit is 1st, Quit is last (opposed to vice-versa)
- faster fading (if fading enabled): 111ms for DockAltTab previews, 333ms for regular previews

# Contributing
[How to build AltTab on Xcode](https://www.youtube.com/watch?v=iitm_r0BBck) --this youtube video shows how to build the official AltTab from lwouis (but this branch has been normalized to be able to build on m-series/apple silicon, so this may not be necessary)
