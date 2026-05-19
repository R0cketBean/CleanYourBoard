# Privacy Policy — CleanYourBoard

_Last updated: 2026-05-19_

CleanYourBoard is designed with one principle: **your keystrokes never leave your Mac.**

## What the app does

CleanYourBoard installs a temporary system-level keyboard event tap while the lock is active. It uses this tap to **swallow** key events so they never reach any application. The events are inspected only long enough to decide whether they should be blocked (yes) or passed through (no — currently nothing is passed through; the unlock combo is detected from the same suppressed stream).

## What we collect

**Nothing.**

- No keystrokes are logged, written to disk, or sent over the network.
- No analytics or telemetry are collected.
- No account is required.
- No personal data is processed.

## Network connections

The only network request the app makes is to **check for updates** via the Sparkle framework. When this happens:

- A single HTTPS request is sent to `https://r0cketbean.github.io/CleanYourBoard/appcast.xml`
- The request contains your macOS version, app version, and CPU architecture (this is standard Sparkle behaviour and used to deliver the right binary)
- No identifier that ties the request to you personally is transmitted

You can disable automatic update checks in CleanYourBoard's **About** panel.

## Accessibility permission

macOS requires you to grant CleanYourBoard "Accessibility" access in **System Settings → Privacy & Security**. This is the OS-level permission needed for any app that listens to keyboard events globally. CleanYourBoard requests it for the single purpose of blocking keys; the permission is not used for any other functionality.

You can revoke the permission at any time. The app will detect this and show its onboarding screen on the next launch.

## Third-party services

- **Sparkle** ([sparkle-project.org](https://sparkle-project.org)) — used only for update delivery, see above. Sparkle is open source and runs entirely locally; the only outbound traffic is the appcast HTTPS request described above.

## Contact

If you have questions or concerns about this policy, please open an issue on the [GitHub repository](https://github.com/R0cketBean/CleanYourBoard/issues).

## Changes to this policy

Any change to this policy will be published in this file with an updated date at the top. Significant changes will additionally be mentioned in release notes.
