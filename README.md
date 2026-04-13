# VPN Status (Live Activity + Shortcuts)

A minimal **iPhone** app that shows a **manually chosen** VPN label in a **Live Activity** and **Dynamic Island**. It does **not** read the system VPN state; Shortcuts (App Intents) pass the desired status.

## Requirements

- Xcode 15+ (iOS **17** deployment target in this project)
- Physical **iPhone** with **Dynamic Island** (14 Pro / 15 Pro / 16 Pro class) to see the island UI; any iPhone on iOS 17+ can show the lock-screen Live Activity
- Apple Developer team selected in Xcode for device installs

## How to run

1. Open `VPNStatus/VPNStatus.xcodeproj` in Xcode.
2. Select your **Development Team** in **Signing & Capabilities** for:
  - Target **VPNStatus**
  - Target **VPNStatusWidgetExtension**
3. Ensure **App Groups** is enabled for both targets with identifier `**group.com.vpnstatus.shared`** (the project already includes entitlements; Xcode may add the capability UI-side).
4. Add a **1024×1024** app icon under **VPNStatus** → **Assets** → **AppIcon** (Xcode may warn until this is set).
5. Choose an **iPhone** run destination and **Run** (⌘R).

First launch: grant **Live Activities** if the system prompts you. You can also allow them under **Settings → VPN Status → Live Activities**.

## Shortcuts (App Intents)

The app registers these actions (see `VPNStatusIntents.swift` and `VPNStatusShortcuts`):


| Action                | Effect                                                    |
| --------------------- | --------------------------------------------------------- |
| **Show Work VPN**     | Starts or updates the Live Activity with **Work VPN**     |
| **Show External VPN** | Starts or updates the Live Activity with **External VPN** |
| **Clear VPN**         | Ends the Live Activity and saves **No VPN**               |
| **Set VPN Status**    | Parameter **Mode**: Work / External / None (clear)        |


### Adding actions on iPhone

1. Open the **Shortcuts** app.
2. Create a new shortcut (or edit your VPN automation).
3. Tap **Add Action** → search for **VPN Status** (your app name) or for the phrase **“Show Work VPN”** (see App Shortcuts phrases in code).
4. Add **Show Work VPN** / **Show External VPN** / **Clear VPN** after your VPN connect/disconnect steps.

Example flow:

1. Run your existing shortcut that toggles the real VPN.
2. Next, run **Show Work VPN** (or the matching action) so the Live Activity matches what you intended.

## Architecture (short)

- `VPNStatus` — enum for **Work VPN**, **External VPN**, **No VPN**
- `VPNActivityAttributes` — `ActivityKit` attributes + `ContentState` for the label
- `VPNStatusStorage` — App Group `UserDefaults` for the last manual state (main app UI)
- `LiveActivityManager` — start / update / end Live Activity
- `VPNStatusWidgetExtension` — Live Activity SwiftUI (lock screen + Dynamic Island)
- App Intents — call `LiveActivityManager` on the main actor

## Known limitation

The UI reflects **only** the status you set via this app or Shortcuts. It does **not** detect whether a real VPN profile is connected, and it does **not** update if the VPN changes outside your shortcuts.

## Bundle IDs (default)

The widget extension’s bundle ID **must** be **exactly** `your.app.bundle.id` + `.` + `suffix` (same string prefix as the app, then a dot and a suffix). Xcode shows *“Embedded binary’s bundle identifier is not prefixed with the parent app’s bundle identifier”* when the **VPNStatus** and **VPNStatusWidgetExtension** targets disagree—often after changing **Signing & Capabilities** on only one target.

This repo sets **explicit** IDs on **both** targets (Debug + Release):

- App: `com.vpnstatus.VPNStatus`
- Widget extension: `com.vpnstatus.VPNStatus.VPNStatusWidget`
- App Group: `group.com.vpnstatus.shared` (update entitlements if you change the group)

The widget `Info.plist` includes `CFBundleIdentifier` = `$(PRODUCT_BUNDLE_IDENTIFIER)`, plus **`CFBundleVersion`** and **`CFBundleShortVersionString`** (currently `1` / `1.0`, matching **Current Project Version** / **Marketing Version** on the app). The simulator install step requires a real **bundle version** on the extension; `INFOPLIST_KEY_*` alone was not enough with a custom plist.

When you bump the app version in Xcode, update those two keys in `VPNStatusWidget/Info.plist` to match.

If you use your own bundle ID, set **`PARENT_APP_BUNDLE_IDENTIFIER`** and **`PRODUCT_BUNDLE_IDENTIFIER`** on **both** targets to stay in sync, then **Product → Clean Build Folder** and rebuild.

**Do not** set the app bundle ID in Xcode to one value (e.g. `com.yourname.vpnstatus`) while the widget still uses `com.vpnstatus.*`—that triggers this error.