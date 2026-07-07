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

@MainActor
public final class FontBlaster {
    /// The font file types supported by FontBlaster.
    private enum SupportedFontExtension: String {
        case trueTypeFont = "ttf"
        case openTypeFont = "otf"
        case trueTypeCollection = "ttc"
    }

    /// Toggles debug print() statements.
    public static var debugEnabled = false

    /// A list of the loaded fonts.
    public static var loadedFonts: [String] = []

    /// Loads all fonts found in a specific bundle. If no value is entered, it defaults to the main bundle.
    public class func blast(bundle: Bundle = Bundle.main) {
        blast(bundle: bundle, completion: nil)
    }

    /// Loads all fonts found in a specific bundle. If no value is entered, it defaults to the main bundle.
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
                                                                   includingPropertiesForKeys: [.isDirectoryKey])
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
    /// - Parameter fontURL: The file URL of the font to register.
    class func loadFont(at fontURL: URL) {
        var registrationError: Unmanaged<CFError>?
        guard CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &registrationError) else {
            let description = (registrationError?.takeRetainedValue()).map { String(describing: $0) } ?? "an unknown error occurred"
            printDebugMessage("Failed to load font '\(fontURL.lastPathComponent)': \(description)")
            return
        }

        guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(fontURL as CFURL) as? [CTFontDescriptor] else {
            printDebugMessage("Loaded font '\(fontURL.lastPathComponent)', but failed to read its PostScript name.")
            return
        }

        for descriptor in descriptors {
            if let postScriptName = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String {
                loadedFonts.append(postScriptName)
                printDebugMessage("Successfully loaded font: '\(postScriptName)'.")
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
