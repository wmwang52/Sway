# 🌊 Sway

*A little iOS app to search & browse Apple Music albums.*

---

## what it is

**Sway** is your own SwiftUI app that talks to Apple Music. You can search for albums, see artwork, and scroll through results—all with a simple, clean flow.

- 🔐 Asks for Apple Music access when needed  
- 🔍 Search albums by artist or anything (default search: Mac Miller)  
- 🎨 Album art, title, and artist in a nice list  

Built with **SwiftUI**, **SwiftData**, and **MusicKit**.

---

## how to run

1. Open `Sway.xcodeproj` in Xcode  
2. Pick a simulator or your device  
3. Run (⌘R)  
4. Tap **Enable Apple Music Access** when prompted  
5. Search and enjoy ~  

*(You’ll need an Apple Developer account / Apple Music subscription for full catalog access.)*

---

## project bits

| File | What it does |
|------|----------------|
| `SwayApp.swift` | App entry, SwiftData container |
| `ContentView.swift` | Auth gate → shows MusicPage when authorized |
| `MusicPage.swift` | Search field + album list + `AlbumRow` |
| `AppMusicAuthorizationManager.swift` | Handles “can we use Music?” and subscription check |

---

## notes for future you

- Auth is handled up front; if denied/restricted, there’s a nudge to open Settings.  
- Search uses `MusicCatalogSearchRequest` for albums only (limit 25).  
- `AlbumRow` uses `AsyncImage` for artwork with a small rounded square.  

That’s it — keep swaying. 🌊
