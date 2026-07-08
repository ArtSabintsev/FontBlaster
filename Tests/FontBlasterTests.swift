//
//  FontBlasterTests.swift
//  FontBlaster
//
//  Created by Arthur Sabintsev on 7/7/26.
//  Copyright (c) 2026 Arthur Ariel Sabintsev. All rights reserved.
//

import XCTest
@testable import FontBlaster

final class FontBlasterTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FontBlaster.loadedFonts = []
        FontBlaster.debugEnabled = false
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
        XCTAssertFalse(firstPass.isEmpty)

        FontBlaster.blast(bundle: .module)
        XCTAssertEqual(FontBlaster.loadedFonts, firstPass,
                       "Re-blasting the same bundle should not append duplicate font names.")
    }

    func testAlreadyRegisteredFontsAreStillReported() {
        FontBlaster.blast(bundle: .module)
        XCTAssertFalse(FontBlaster.loadedFonts.isEmpty)

        // A consumer that resets the list and re-blasts should still learn the font names,
        // even though CoreText reports the files as already registered.
        FontBlaster.loadedFonts = []
        FontBlaster.blast(bundle: .module)
        XCTAssertTrue(FontBlaster.loadedFonts.contains("OpenSans"),
                      "Already-registered fonts should be re-reported. Loaded: \(FontBlaster.loadedFonts)")
    }

    func testBlastLoadsFontsFromDirectoryOutsideAnyBundleAndIgnoresExtensionCase() throws {
        let sourceURL = try XCTUnwrap(Bundle.module.url(forResource: "OpenSans-Regular",
                                                        withExtension: "ttf",
                                                        subdirectory: "Fonts"))
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("FontBlasterTests \(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        try FileManager.default.copyItem(at: sourceURL,
                                         to: directoryURL.appendingPathComponent("OpenSans-Regular.TTF"))

        let bundle = try XCTUnwrap(Bundle(path: directoryURL.path))
        FontBlaster.blast(bundle: bundle)

        XCTAssertTrue(FontBlaster.loadedFonts.contains("OpenSans"),
                      "Expected an uppercase-extension font in a temporary directory to load. Loaded: \(FontBlaster.loadedFonts)")
    }

    func testInvalidFontFileIsIgnored() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("FontBlasterTests \(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        try Data("not a font".utf8).write(to: directoryURL.appendingPathComponent("Broken.ttf"))

        let bundle = try XCTUnwrap(Bundle(path: directoryURL.path))
        FontBlaster.blast(bundle: bundle)

        XCTAssertTrue(FontBlaster.loadedFonts.isEmpty,
                      "An invalid font file should not be reported as loaded. Loaded: \(FontBlaster.loadedFonts)")
    }
}
