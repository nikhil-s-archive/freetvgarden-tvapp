# Live TV (tvOS-style IPTV for Android TV)

Kotlin + Jetpack Compose + Media3 (ExoPlayer). Channels come from the `streams/` folder of
https://github.com/iptv-org/iptv, grouped by country.

Build: open this folder in Android Studio (Ladybug or newer) -> Sync -> Run on an Android TV
emulator/device. Or: Build > Build APK(s), then `adb install app-debug.apk`.

Remote: D-pad to move, OK to open, hold OK on a channel to toggle favourite.
Player: Up/Down changes channel, OK shows controls, Back hides controls / exits.
