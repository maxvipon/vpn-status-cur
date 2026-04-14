# LA Status (Live Activity + Shortcuts)

A minimal **iPhone** app that shows a **manually chosen** label in a **Live Activity** and **Dynamic Island**. It does **not** read any system VPN state; Shortcuts (App Intents) pass the labels to display.

## Requirements

- Xcode 15+ (iOS **17** deployment target in this project)
- Physical **iPhone** with **Dynamic Island** (14 Pro / 15 Pro / 16 Pro class) to see the island UI; any iPhone on iOS 17+ can show the lock-screen Live Activity
- Apple Developer team selected in Xcode for device installs

## How to run

1. Open `LAStatus/LAStatus.xcodeproj` in Xcode.
2. Select your **Development Team** in **Signing & Capabilities** for:
  - Target **LAStatus**
  - Target **LAStatusWidgetExtension**
3. Ensure **App Groups** is enabled for both targets with identifier `group.com.lastatus.shared` (the project already includes entitlements; Xcode may add the capability UI-side).
4. Add a **1024×1024** app icon under **LAStatus** → **Assets** → **AppIcon** (Xcode may warn until this is set).
5. Choose an **iPhone** run destination and **Run** (⌘R).

First launch: grant **Live Activities** if the system prompts you. You can also allow them under **Settings → LA Status → Live Activities**.

## Shortcuts (App Intents)

The app registers these actions (see `LAShortcutsIntents.swift`):

| Action                   | Effect                                                                 |
| ------------------------ | ---------------------------------------------------------------------- |
| **Show Live Activity**   | Starts or updates using parameters `Live Activity Label` + `Dynamic Island Label` |
| **Hide Live Activity**   | Ends the Live Activity and saves `No LA`                              |

Shortcuts actions use **`LiveActivityIntent`**. That is what lets the system start or update the Live Activity when the app is **not** in the foreground. A normal `AppIntent` calling `Activity.request` is not enough for background/Shortcuts-only runs.

### Adding actions on iPhone

1. Open the **Shortcuts** app.
2. Create a new shortcut (or edit your automation).
3. Tap **Add Action** → search for **LA Status** (your app name) or **Show Live Activity**.
4. Add **Show Live Activity** (set both labels) and **Hide Live Activity** where needed.

Example flow:

1. Run your existing shortcut.
2. Next, run **Show Live Activity** with your labels so the Live Activity matches what you intended.

## Architecture (short)

- `LAStatus` — minimal state enum (`active` / `none`)
- `LAActivityAttributes` — `ActivityKit` attributes + `ContentState` with two labels
- `LAStatusStorage` — App Group `UserDefaults` for the last manual state
- `LALiveActivityManager` — start / update / end Live Activity
- `LAStatusWidgetExtension` — Live Activity SwiftUI (lock screen + Dynamic Island)
- App Intents — call `LALiveActivityManager` on the main actor

## Known limitation

The UI reflects **only** the labels you set via this app or Shortcuts. It does **not** detect any real VPN profile state, and it does **not** update if network state changes outside your shortcuts.

## Bundle IDs (default)

The widget extension’s bundle ID **must** be **exactly** `your.app.bundle.id` + `.` + `suffix` (same string prefix as the app, then a dot and a suffix). Xcode shows *“Embedded binary’s bundle identifier is not prefixed with the parent app’s bundle identifier”* when the **LAStatus** and **LAStatusWidgetExtension** targets disagree—often after changing **Signing & Capabilities** on only one target.

This repo sets **explicit** IDs on **both** targets (Debug + Release):

- App: `com.lastatus.LAStatus`
- Widget extension: `com.lastatus.LAStatus.LAStatusWidget`
- App Group: `group.com.lastatus.shared` (update entitlements if you change the group)

The widget `Info.plist` is **custom** (not fully generated), so it must include the usual bundle keys Xcode would inject otherwise: **`CFBundleExecutable`** (literal **`LAStatusWidgetExtension`**, matching the extension target product name), **`CFBundlePackageType`** (`XPC!`), **`CFBundleIdentifier`**, **`CFBundleName`**, plus **`CFBundleVersion`** / **`CFBundleShortVersionString`** (currently `1` / `1.0`, matching the app). Without a valid **`CFBundleExecutable`**, simulator install fails with *missing or invalid CFBundleExecutable*.

When you bump the app version in Xcode, update those two keys in `LAStatusWidget/Info.plist` to match.

If you use your own bundle ID, set **`PARENT_APP_BUNDLE_IDENTIFIER`** and **`PRODUCT_BUNDLE_IDENTIFIER`** on **both** targets to stay in sync, then **Product → Clean Build Folder** and rebuild.

**Do not** set the app bundle ID in Xcode to one value while the widget still uses another prefix—that triggers this error.
