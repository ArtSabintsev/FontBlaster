// © 2015 Arthur Ariel Sabintsev. All rights reserved.

import CoreGraphics
import CoreText
import UIKit

public final class FontBlaster {
  public static var debugEnabled = false
  public static var loadedFonts: [String] = []

  public class func blast(
    bundle: Bundle = .main,
    completion handler: (([String]) -> Void)? = nil
  ) {
    let path = bundle.bundlePath
    loadFontsForBundle(path)
    loadFontsFromBundlesFoundInBundle(path)
    handler?(loadedFonts)
  }
}

typealias FontPath = String
typealias FontName = String
typealias FontExtension = String
typealias Font = (path: FontPath, name: FontName, ext: FontExtension)

enum SupportedFontExtensions: String {
  case trueType = "ttf"
  case openType = "otf"

  init?(_ v: String?) {
    if SupportedFontExtensions.trueType.rawValue == v {
      self = .trueType
    } else if SupportedFontExtensions.openType.rawValue == v {
      self = .openType
    } else {
      return nil
    }
  }
}

extension FontBlaster {
  class func loadFontsForBundle(_ path: String) {
    do {
      let contents = try FileManager.default.contentsOfDirectory(atPath: path)
      let loadedFonts = fonts(path, contents)
      if !loadedFonts.isEmpty {
        for font in loadedFonts {
          loadFont(font)
        }
      } else {
        log("No fonts were found in the bundle path: \(path).")
      }
    } catch let error as NSError {
      log("""
      There was an error loading fonts from the bundle.
      Path: \(path).
      Error: \(error)
      """)
    }
  }

  class func loadFontsFromBundlesFoundInBundle(_ path: String) {
    do {
      let contents = try FileManager.default.contentsOfDirectory(atPath: path)
      for item in contents {
        guard let url = URL(string: path), item.contains(".bundle") else {
          continue
        }
        let urlPathString = url.appendingPathComponent(item).absoluteString
        loadFontsForBundle(urlPathString)
      }
    } catch let error as NSError {
      log("""
      There was an error accessing bundle with path.
      Path: \(path).
      Error: \(error)
      """)
    }
  }

  class func loadFont(_ font: Font) {
    let path: FontPath = font.path
    let name: FontName = font.name
    let ext: FontExtension = font.ext
    let fileURL = URL(fileURLWithPath: path)
      .appendingPathComponent(name)
      .appendingPathExtension(ext)

    var error: Unmanaged<CFError>?
    if let data = try? Data(contentsOf: fileURL) as CFData,
      let dataProvider = CGDataProvider(data: data) {
      workaroundDeadlock()

      let ref = CGFont(dataProvider)

      if CTFontManagerRegisterGraphicsFont(ref!, &error) {
        if let postScriptName = ref?.postScriptName {
          log("Successfully loaded font: '\(postScriptName)'.")
          loadedFonts.append(String(postScriptName))
        }
      } else if let error = error?.takeRetainedValue() {
        let errorDescription = CFErrorCopyDescription(error)
        log("Failed to load font '\(name)': \(String(describing: errorDescription))")
      }
    } else {
      guard let error = error?.takeRetainedValue() else {
        log("Failed to load font '\(name)'.")
        return
      }
      let errorDescription = CFErrorCopyDescription(error)
      log("Failed to load font '\(name)': \(String(describing: errorDescription))")
    }
  }

  class func workaroundDeadlock() {
    _ = UIFont.systemFont(ofSize: 10)
  }
}

extension FontBlaster {
  class func fonts(_ path: String, _ contents: [String]) -> [Font] {
    var fonts = [Font]()
    for name in contents {
      if let parsedFont = font(name) {
        fonts.append((path, parsedFont.0, parsedFont.1))
      }
    }
    return fonts
  }

  class func font(_ name: String) -> (FontName, FontExtension)? {
    let comps = name.components(separatedBy: ".")
    if comps.count < 2 { return nil }
    let fname = comps[0 ..< comps.count - 1].joined(separator: ".")
    let ext = comps.last!
    return SupportedFontExtensions(ext) != nil ? (fname, ext) : nil
  }

  class func log(_ message: String) {
    if debugEnabled == true {
      print("[FontBlaster]: \(message)")
    }
  }
}
