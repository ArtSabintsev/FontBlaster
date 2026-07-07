//
//  FontBlasterTests.swift
//  FontBlaster
//
//  Created by Arthur Sabintsev on 7/7/26.
//  Copyright (c) 2026 Arthur Ariel Sabintsev. All rights reserved.
//

import XCTest
@testable import FontBlaster

@MainActor
final class FontBlasterTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FontBlaster.debugEnabled = true
    }

    func testBlastLoadsAllBundledFonts() {
        var reportedFonts: [String] = []
        FontBlaster.blast(bundle: .module) { fonts in
            reportedFonts = fonts
        }

        XCTAssertTrue(reportedFonts.contains("OpenSans"),
                      "Expected OpenSans-Regular.ttf to register as 'OpenSans'. Loaded: \(reportedFonts)")
        XCTAssertTrue(reportedFonts.contains("OpenSans-Bold"),
                      "Expected OpenSans-Bold.ttf to register as 'OpenSans-Bold'. Loaded: \(reportedFonts)")
        XCTAssertEqual(reportedFonts, FontBlaster.loadedFonts)
    }

    func testRepeatedBlastDoesNotDuplicateLoadedFonts() {
        FontBlaster.blast(bundle: .module)
        let firstPass = FontBlaster.loadedFonts

        FontBlaster.blast(bundle: .module)
        XCTAssertEqual(FontBlaster.loadedFonts, firstPass,
                       "Re-blasting the same bundle should not append duplicate font names.")
    }
}
