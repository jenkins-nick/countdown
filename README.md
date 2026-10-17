# Countdown

A simple iOS app that counts down the days to the dates you care about, with widgets for the Home Screen and Lock Screen.

- Add as many countdowns as you like: title, emoji, date (and an optional time) and a color.
- Tap one for a live days / hours / minutes / seconds view.
- Widgets: small and medium on the Home Screen; circular, rectangular and inline on the Lock Screen.
- Each widget can show a specific countdown (long-press → **Edit Widget**). If you don't pick one, it shows your next upcoming countdown.
- On the day of a countdown with a time set, the widget switches to a live ticking timer.

Requires iOS 17 or later and Xcode 16 or later.

## Run it on your iPhone

1. Open `Countdown.xcodeproj` in Xcode.
2. Select the **Countdown** project in the sidebar, then **Build Settings** for the project (not a target), and change `BASE_BUNDLE_ID` from `com.jenkinsnick.Countdown` to something unique to you, e.g. `com.yourname.Countdown`. The app's bundle ID, the widget's bundle ID (`….Widget`) and the shared App Group (`group.…`) all come from this one setting.
3. For **both** the `Countdown` and `CountdownWidgetExtension` targets, open **Signing & Capabilities** and choose your **Team**.
4. Plug in your iPhone (or pick a simulator), select the **Countdown** scheme, and press **Run** (⌘R).

The first time you run it on a device you may need to trust the developer certificate under **Settings → General → VPN & Device Management**.

### Adding the widgets

- **Home Screen:** long-press an empty area → **Edit** → **Add Widget** → search for **Countdown**.
- **Lock Screen:** long-press the Lock Screen → **Customize** → **Lock Screen** → tap the widget area → **Countdown**.

To choose which countdown a widget shows, long-press it and pick **Edit Widget**.

### About the App Group

The app and widget share data through an App Group (`group.<BASE_BUNDLE_ID>`). Xcode registers it automatically when you pick your team. If signing reports a problem with App Groups, open **Signing & Capabilities** on each target, remove the App Groups capability, add it back, and tick `group.<your BASE_BUNDLE_ID>`. Without a working App Group the app still works, but the widget won't see your countdowns.

## Project layout

| Folder | What's in it |
| --- | --- |
| `Countdown/` | The app: list, detail and edit screens |
| `CountdownWidget/` | The widget extension and its "Choose Countdown" configuration |
| `Shared/` | The data model and storage, compiled into both targets |
| `Config/` | Info.plist and entitlements files |
