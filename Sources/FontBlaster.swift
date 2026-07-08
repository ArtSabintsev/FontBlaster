//
//  FontBlaster.swift
//  FontBlaster
//
//  Created by Arthur Sabintsev on 5/5/15.
//  Copyright (c) 2015 Arthur Ariel Sabintsev. All rights reserved.
//

import CoreText
import Foundation

// MARK: - FontBlaster

public final class FontBlaster {
    /// The font file types supported by FontBlaster.
    private enum SupportedFontExtension: String {
        case trueTypeFont = "ttf"
        case openTypeFont = "otf"
        case trueTypeCollection = "ttc"
    }

    /// Lock-protected mutable state, so `blast()` may be called from any thread.
    private final class State: @unchecked Sendable {
        let lock = NSLock()
        var debugEnabled = false
        var loadedFonts: [String] = []
    }

    private static let state = State()

    /// Toggles debug print() statements.
    public static var debugEnabled: Bool {
        get { state.lock.withLock { state.debugEnabled } }
        set { state.lock.withLock { state.debugEnabled = newValue } }
    }

    /// A list of the loaded fonts.
    public static var loadedFonts: [String] {
        get { state.lock.withLock { state.loadedFonts } }
        set { state.lock.withLock { state.loadedFonts = newValue } }
    }

    /// Loads all fonts found in a specific bundle. If no value is entered, it defaults to the main bundle.
    public class func blast(bundle: Bundle = Bundle.main) {
        blast(bundle: bundle, completion: nil)
    }

    /// Loads all fonts found in a specific bundle. If no value is entered, it defaults to the main bundle.
    ///
    /// Registered fonts are file-backed: do not move or delete a font file while it remains registered.
    ///
    /// - Parameters:
    ///   - bundle: The bundle to scan for fonts.
    ///   - handler: Returns an array of strings containing the names of the fonts that were loaded.
    public class func blast(bundle: Bundle = Bundle.main, completion handler: (([String]) -> Void)?) {
        loadFonts(in: bundle.bundleURL)
        handler?(loadedFonts)
    }
}

// MARK: - Helpers (Font Loading)

private extension FontBlaster {
    /// Recursively loads all fonts found in a directory, descending into subdirectories and nested bundles.
    ///
    /// - Parameter directoryURL: The file URL of the directory to scan.
    class func loadFonts(in directoryURL: URL) {
        printDebugMessage("Scanning \(directoryURL.path) for fonts.")

        let contents: [URL]
        do {
            contents = try FileManager.default.contentsOfDirectory(at: directoryURL,
                                                                   includingPropertiesForKeys: [.isDirectoryKey],
                                                                   options: [.skipsHiddenFiles])
        } catch {
            printDebugMessage("There was an error scanning \(directoryURL.path): \(error)")
            return
        }

        for url in contents {
            let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            if isDirectory {
                loadFonts(in: url)
            } else if SupportedFontExtension(rawValue: url.pathExtension.lowercased()) != nil {
                loadFont(at: url)
            }
        }
    }

    /// Registers a font file with the font manager and records the PostScript name of every font it contains.
    ///
    /// A font that is already registered (in this or an earlier launch of the process) is treated as
    /// loaded, not as a failure, so its names are still recorded.
    ///
    /// - Parameter fontURL: The file URL of the font to register.
    class func loadFont(at fontURL: URL) {
        var registrationError: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &registrationError) {
            let error = registrationError?.takeRetainedValue()
            guard let error, isAlreadyRegistered(error) else {
                let description = error.map { String(describing: $0) } ?? "an unknown error occurred"
                printDebugMessage("Failed to load font '\(fontURL.lastPathComponent)': \(description)")
                return
            }
            printDebugMessage("Font '\(fontURL.lastPathComponent)' is already registered.")
        }

        guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(fontURL as CFURL) as? [CTFontDescriptor] else {
            printDebugMessage("Loaded font '\(fontURL.lastPathComponent)', but failed to read its PostScript name.")
            return
        }

        for descriptor in descriptors {
            if let postScriptName = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String {
                recordLoadedFont(postScriptName)
                printDebugMessage("Successfully loaded font: '\(postScriptName)'.")
            }
        }
    }

    /// Whether a registration error means the font is already available to the process.
    ///
    /// - Parameter error: The error returned by font registration.
    class func isAlreadyRegistered(_ error: CFError) -> Bool {
        guard CFErrorGetDomain(error) as String == kCTFontManagerErrorDomain as String else {
            return false
        }
        let code = CFErrorGetCode(error)
        return code == CTFontManagerError.alreadyRegistered.rawValue
            || code == CTFontManagerError.duplicatedName.rawValue
    }

    /// Appends a font name to `loadedFonts` if it is not already recorded.
    ///
    /// - Parameter name: The PostScript name of the loaded font.
    class func recordLoadedFont(_ name: String) {
        state.lock.withLock {
            if !state.loadedFonts.contains(name) {
                state.loadedFonts.append(name)
            }
        }
    }
}

// MARK: - Helpers (Miscellaneous)

private extension FontBlaster {
    /// Prints debug messages to the console if debugEnabled is set to true.
    ///
    /// - Parameter message: The status to print to the console.
    class func printDebugMessage(_ message: String) {
        if debugEnabled {
            print("[FontBlaster]: \(message)")
        }
    }
}
