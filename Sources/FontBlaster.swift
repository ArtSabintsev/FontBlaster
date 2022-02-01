//
//  FontBlaster.swift
//  FontBlaster
//
//  Created by Arthur Sabintsev on 5/5/15.
//  Copyright (c) 2015 Arthur Ariel Sabintsev. All rights reserved.
//

import CoreGraphics
import CoreText
import Foundation

// MARK: - FontBlaster

final public class FontBlaster {
    fileprivate enum SupportedFontExtensions: String {
        case TrueTypeFont = ".ttf"
        case OpenTypeFont = ".otf"
    }

    fileprivate typealias FontPath = String
    fileprivate typealias FontName = String
    fileprivate typealias FontExtension = String
    fileprivate typealias Font = (path: FontPath, name: FontName, ext: FontExtension)

    /// Toggles debug print() statements
    public static var debugEnabled = false

    /// A list of the loaded fonts
    public static var loadedFonts: [String] = []

    /// Load all fonts found in a specific bundle. If no value is entered, it defaults to the main bundle.
    public class func blast(bundle: Bundle = Bundle.main) {
        blast(bundle: bundle, completion: nil)
    }

    /**
     Load all fonts found in a specific bundle. If no value is entered, it defaults to the main bundle.

     - returns: An array of strings containing the names of the fonts that were loaded.
     */
    public class func blast(bundle: Bundle = Bundle.main, completion handler: (([String])->Void)?) {
        let path = bundle.bundlePath
        loadFontsForBundle(withPath: path)
        loadFontsFromBundlesFoundInBundle(path: path)
        handler?(loadedFonts)
    }
}

// MARK: - Helpers (Font Loading)

private extension FontBlaster {
    /// Loads all fonts found in a bundle.
    ///
    /// - Parameter path: The absolute path to the bundle.
    final class func loadFontsForBundle(withPath path: String) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path) as [String]
            let loadedFonts = fonts(fromPath: path, withContents: contents)
            if !loadedFonts.isEmpty {
                loadedFonts.forEach { font in
                    loadFont(font: font)
                }
            } else {
                printDebugMessage(message: "No fonts were found in the bundle path: \(path).")
            }
        } catch let error as NSError {
            printDebugMessage(message: "There was an error loading fonts from the bundle. \nPath: \(path).\nError: \(error)")
        }
    }

    /// Loads all fonts found in a bundle that is loaded within another bundle.
    ///
    /// - Parameter path: The absolute path to the bundle.
    final class func loadFontsFromBundlesFoundInBundle(path: String) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)
            contents.forEach { item in
                if let url = URL(string: path),
                    item.contains(".bundle") {
                    let urlPathString = url.appendingPathComponent(item).absoluteString
                    loadFontsForBundle(withPath: urlPathString)
                }
            }
        } catch let error as NSError {
            printDebugMessage(message: "There was an error accessing bundle with path. \nPath: \(path).\nError: \(error)")
        }
    }

    /// Loads a specific font.
    ///
    /// - Parameter font: The font to load.
    final class func loadFont(font: Font) {
        let fontPath: FontPath = font.path
        let fontName: FontName = font.name
        let fontExtension: FontExtension = font.ext
        let fontFileURL = URL(fileURLWithPath: fontPath).appendingPathComponent(fontName).appendingPathExtension(fontExtension)

        var fontError: Unmanaged<CFError>?
        if let fontData = try? Data(contentsOf: fontFileURL) as CFData,
            let dataProvider = CGDataProvider(data: fontData) {

            guard let fontRef = CGFont(dataProvider) else {
                printDebugMessage(message: "Failed to load font: '\(fontName)': fontRef is nil")
                return
            }

            if CTFontManagerRegisterGraphicsFont(fontRef, &fontError),
               let postScriptName = fontRef.postScriptName {
                    printDebugMessage(message: "Successfully loaded font: '\(postScriptName)'.")
                    loadedFonts.append(String(postScriptName))
            } else if let fontError = fontError?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(fontError)
                printDebugMessage(message: "Failed to load font '\(fontName)': \(String(describing: errorDescription))")
            }
        } else {
            guard let fontError = fontError?.takeRetainedValue() else {
                printDebugMessage(message: "Failed to load font '\(fontName)'.")
                return
            }

            let errorDescription = CFErrorCopyDescription(fontError)
            printDebugMessage(message: "Failed to load font '\(fontName)': \(String(describing: errorDescription))")
        }
    }
}

// MARK: - Helpers (Miscellaneous)

private extension FontBlaster {
    /// Parses all of the fonts into their name and extension components.
    ///
    /// - Parameters:
    ///     - path: The absolute path to the font file.
    ///     - contents: The contents of an Bundle as an array of String objects.
    /// 
    /// - Returns: A an array of Font objects.
    final class func fonts(fromPath path: String, withContents contents: [String]) -> [Font] {
        var fonts = [Font]()
        for fontName in contents {
            var parsedFont: (FontName, FontExtension)?

            if fontName.contains(SupportedFontExtensions.TrueTypeFont.rawValue) || fontName.contains(FontBlaster.SupportedFontExtensions.OpenTypeFont.rawValue) {
                parsedFont = font(fromName: fontName)
            }

            if let parsedFont = parsedFont {
                let font: Font = (path, parsedFont.0, parsedFont.1)
                fonts.append(font)
            }
        }

        return fonts
    }

    /// Parses a font into its name and extension components.
    ///
    /// - Parameter name: The name of the font.
    /// 
    /// - Returns: A tuple with the font's name and extension.
    final class func font(fromName name: String) -> (FontName, FontExtension) {
        let components = name.split{$0 == "."}.map { String($0) }
        return (components[0], components[1])
    }

    /// Prints debug messages to the console if debugEnabled is set to true.
    ///
    /// - Parameter message: The status to print to the console.
    final class func printDebugMessage(message: String) {
        if debugEnabled == true {
            print("[FontBlaster]: \(message)")
        }
    }
}
