# Release Playbook

Step-by-step for cutting a new version of **CleanYourBoard**. The first time through is the most work (Sparkle key generation, GitHub Pages setup); after that, every subsequent release is ~10 minutes.

---

## One-time setup

### 1. Add Sparkle to the project

In Xcode:

1. **File → Add Package Dependencies…**
2. Enter URL: `https://github.com/sparkle-project/Sparkle`
3. Dependency Rule: **Up to Next Major Version**, starting from `2.0.0`
4. Target: `CleanYourBoard - Keyboard Cleaner`
5. **Add Package**

`Updater.swift` already contains `#if canImport(Sparkle)` so the Sparkle code activates the moment the package is on the build path.

### 2. Generate the Sparkle signing key pair

The Sparkle Swift package ships a `generate_keys` binary inside its `.swiftpm` artifacts. Easiest way:

```bash
# After Xcode has resolved the package once:
SPARKLE_BIN=$(find ~/Library/Developer/Xcode/DerivedData -name generate_keys -type f 2>/dev/null | head -1)
"$SPARKLE_BIN"
```

It prints something like:

```
A key has been generated and saved in your keychain.
Public key (length 44, encoded as base64):
SUPublicEDKey
abcdef0123456789…
```

- The **private** key now lives in your Login Keychain — `generate_keys` placed it there. **Never share it.** It signs every update binary.
- The **public** key string is what you put into the app's `Info.plist`.

### 3. Add Sparkle Info.plist keys

Open `CleanYourBoard - Keyboard Cleaner.xcodeproj` → Target → **Build Settings** → search "Info.plist", and add these two keys via **Info** tab (or via `INFOPLIST_KEY_*` in pbxproj):

| Key              | Value                                                                |
|------------------|----------------------------------------------------------------------|
| `SUFeedURL`      | `https://r0cketbean.github.io/CleanYourBoard/appcast.xml`             |
| `SUPublicEDKey`  | _(the base64 string from `generate_keys`)_                            |
| `SUEnableInstallerLauncherService` | `YES` _(if you ship the Sparkle XPC services)_  |

### 4. Create a GitHub Pages branch

```bash
git switch --orphan gh-pages
echo "CleanYourBoard release feed" > README.md
git add README.md
git commit -m "Init gh-pages branch"
git push -u origin gh-pages
git switch main
```

In the GitHub repo: **Settings → Pages → Source: gh-pages branch / root**. Pages publishes `https://r0cketbean.github.io/CleanYourBoard/`.

---

## Per-release workflow

### 1. Bump the version

In Xcode → Target → General:
- **Version:** `1.0.1` (semantic, user-visible)
- **Build:** `2` (monotonic integer, internal)

Commit both bumps.

### 2. Archive and notarize

```
Product → Archive
↓
Organizer opens → "Distribute App"
↓
"Developer ID" → "Upload" (sends to Apple notarisation, 5–30 min)
↓
"Export Notarized App"
```

This dumps a notarised `CleanYourBoard.app` somewhere; remember the path.

### 3. Wrap in a DMG

```bash
brew install create-dmg  # one-time

create-dmg \
    --volname "CleanYourBoard 1.0.1" \
    --window-size 540 380 \
    --icon-size 100 \
    --icon "CleanYourBoard.app" 140 200 \
    --app-drop-link 400 200 \
    --hide-extension "CleanYourBoard.app" \
    CleanYourBoard-1.0.1.dmg \
    "/path/to/CleanYourBoard.app"
```

### 4. Sign + notarize the DMG

```bash
codesign --sign "Developer ID Application: <YOUR NAME> (8QQHV834VF)" \
         CleanYourBoard-1.0.1.dmg

xcrun notarytool submit CleanYourBoard-1.0.1.dmg \
                       --apple-id "<your-apple-id-email>" \
                       --team-id 8QQHV834VF \
                       --keychain-profile "AC_NOTARY" \
                       --wait

xcrun stapler staple CleanYourBoard-1.0.1.dmg
```

> Tip: `xcrun notarytool store-credentials AC_NOTARY` (one-time) avoids retyping the app-specific password every release.

### 5. Sign the DMG for Sparkle

```bash
SIGN_BIN=$(find ~/Library/Developer/Xcode/DerivedData -name sign_update -type f 2>/dev/null | head -1)
"$SIGN_BIN" CleanYourBoard-1.0.1.dmg
# Prints:
#   sparkle:edSignature="…" length="…"
```

Copy that signature line — you'll paste it into the appcast next.

### 6. Update the appcast (gh-pages branch)

`appcast.xml` skeleton (push to `gh-pages` branch root):

```xml
<?xml version="1.0" standalone="yes"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"
     xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
  <channel>
    <title>CleanYourBoard</title>
    <link>https://github.com/R0cketBean/CleanYourBoard</link>
    <description>Updates to CleanYourBoard.</description>
    <language>en</language>

    <item>
      <title>Version 1.0.1</title>
      <pubDate>Wed, 19 May 2026 12:00:00 +0000</pubDate>
      <sparkle:version>2</sparkle:version>
      <sparkle:shortVersionString>1.0.1</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
      <description><![CDATA[
        <ul>
          <li>Fixed: …</li>
          <li>Added: …</li>
        </ul>
      ]]></description>
      <enclosure
        url="https://github.com/R0cketBean/CleanYourBoard/releases/download/v1.0.1/CleanYourBoard-1.0.1.dmg"
        sparkle:edSignature="<paste from step 5>"
        length="<file size in bytes>"
        type="application/octet-stream"/>
    </item>

    <!-- Older releases stay as additional <item> entries -->
  </channel>
</rss>
```

Commit & push:

```bash
git switch gh-pages
# update appcast.xml
git add appcast.xml
git commit -m "Release 1.0.1"
git push
git switch main
```

GitHub Pages publishes the new feed within ~1 minute.

### 7. Create the GitHub Release

```bash
git tag v1.0.1
git push origin v1.0.1
```

Then on github.com → Releases → **Draft a new release**:
- Tag: `v1.0.1`
- Title: `CleanYourBoard 1.0.1`
- Notes: paste the same changelog as the appcast `<description>`
- **Attach** `CleanYourBoard-1.0.1.dmg`
- Publish

Sparkle now finds the new build automatically and offers an in-app update to your users.

---

## Quick checklist

- [ ] Version bumped (`Version` + `Build`)
- [ ] Archive → notarized → exported `.app`
- [ ] DMG built and notarized
- [ ] DMG Sparkle-signed (`sign_update`)
- [ ] `appcast.xml` updated on `gh-pages` and pushed
- [ ] GitHub Release created with DMG attached
- [ ] Verify update appears via app's "Check for Updates"

## Common pitfalls

- **"App is damaged" on download** → DMG was not notarised, or stapler step was skipped.
- **Sparkle says "no update available"** → the appcast `<sparkle:version>` (build number) must be **higher** than the currently installed build number. Bump it every release.
- **`SUPublicEDKey` mismatch** → you generated a new key pair instead of using the existing one. Use the same key for every release. Back up the key (export from Keychain).
- **GitHub-Pages 404** → check `Settings → Pages → Source` is set to `gh-pages` branch and the file is at the **root** of that branch.

## Backups you need

1. **Apple Developer ID Application certificate** — exported as `.p12` with password, stored somewhere safe. Without it, you can never sign another update users will accept.
2. **Sparkle private key** — exported from Keychain. Without it, you can never sign another update Sparkle will accept.
3. **Apple ID app-specific password** for `notarytool`.

Losing any of these effectively blocks you from publishing further updates under the same identity.
