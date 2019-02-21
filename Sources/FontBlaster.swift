// © 2015 Arthur Ariel Sabintsev. All rights reserved.

import CoreGraphics
import CoreText
import UIKit

public final class FontBlaster {
  public static var debugEnabled = false
  public static var loadedFonts: [String] = []

  public class func blast(
    atPath path: String?,
    completion handler: (([String]) -> Void)? = nil
  ) {
    guard let path = path else {
      handler?(loadedFonts)
      return
    }
    blast(at: URL(string: path), completion: handler)
  }

  public class func blast(
    bundle: Bundle = .main,
    completion handler: (([String]) -> Void)? = nil
  ) {
    blast(at: bundle.bundleURL, completion: handler)
  }

  public class func blast(
    at url: URL?,
    completion handler: (([String]) -> Void)? = nil
  ) {
    guard let url = url else {
      handler?(loadedFonts)
      return
    }
    loadFonts(at: url)
    loadFontsFromBundles(at: url)
    handler?(loadedFonts)
  }
}

typealias FontPath = URL
typealias FontName = String
typealias FontExtension = String
typealias Font = (url: FontPath, name: FontName, ext: FontExtension)

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
  class func loadFonts(at url: URL) {
    do {
      let contents = try FileManager.default.contentsOfDirectory(
        at: url,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
      )
      let loadedFonts = fonts(contents)
      if !loadedFonts.isEmpty {
        for font in loadedFonts {
          loadFont(font)
        }
      } else {
        log("No fonts were found in url: \(url).")
      }
    } catch let error as NSError {
      log("""
      There was an error loading fonts.
      Path: \(url).
      Error: \(error)
      """)
    }
  }

  class func loadFontsFromBundles(at url: URL) {
    do {
      let contents = try FileManager.default.contentsOfDirectory(
        at: url,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
      )
      for item in contents {
        guard item.absoluteString.contains(".bundle") else {
          continue
        }
        loadFonts(at: item)
      }
    } catch let error as NSError {
      log("""
      There was an error accessing bundle with url.
      Path: \(url).
      Error: \(error)
      """)
    }
  }

  class func loadFont(_ font: Font) {
    let fileURL: FontPath = font.url
    let name = font.name
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
  class func fonts(_ contents: [URL]) -> [Font] {
    var fonts = [Font]()
    for fontUrl in contents {
      if let parsedFont = font(fontUrl) {
        fonts.append((fontUrl, parsedFont.0, parsedFont.1))
      }
    }
    return fonts
  }

  class func font(_ fontUrl: URL) -> (FontName, FontExtension)? {
    let name = fontUrl.lastPathComponent
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
