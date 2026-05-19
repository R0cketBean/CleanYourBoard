//
//  Credits.swift
//  CleanYourBoard - Keyboard Cleaner
//
//  Public author:   R0cketBean
//  Legal author:    Andreas "Andy" Bröder
//  Apple Team ID:   8QQHV834VF
//
//  All user-facing copyright, About panel, App Store / website,
//  README and social references use the "R0cketBean" handle.
//
//  The legal name is recorded here because:
//    1. The Developer ID signing certificate carries it (visible via
//       `codesign -dvv` on the signed binary). Switching to an Apple
//       Developer "Organisation" account would mask the name on the
//       signature too, but requires a registered company + D-U-N-S.
//    2. Anyone reviewing or contributing to the source code should be
//       able to attribute changes correctly even if the public face
//       only shows the pseudonym.
//
//  Do not surface `legalAuthor` in the UI. It exists solely as
//  authorship metadata for the codebase.
//

import Foundation

enum AppCredits {
    static let publicAuthor  = "R0cketBean"
    static let legalAuthor   = "Andreas Bröder"
    static let copyrightYear = 2026
    static let copyrightLine = "© \(copyrightYear) \(publicAuthor). All rights reserved."
}
