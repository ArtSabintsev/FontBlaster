// © 2015 Arthur Ariel Sabintsev. All rights reserved.

import CoreGraphics
import CoreText
import UIKit

public final class FontBlaster {
  public static var debugEnabled = false

  public class func blast(
    atPath path: String?,
    completion handler: (([String]) -> Void)? = nil
  ) {
    guard let path = path else {
      handler?([])
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
      handler?([])
      return
    }
    var loadedFonts: [Font] = []
    loadedFonts += loadFonts(at: url)
    loadedFonts += loadFontsFromBundles(at: url)

    let alreadyLoaded = allLoadedFonts.map { $0.url }
    let justLoaded = loadedFonts.map { $0.url }
    for i in 0 ..< justLoaded.count {
      let justLoadedUrl = justLoaded[i]
      if alreadyLoaded.index(of: justLoadedUrl) == nil {
        allLoadedFonts.append(loadedFonts[i])
      }
    }

    handler?(loadedFonts.map { $0.name })
  }
}

typealias FontPath = URL
typealias FontName = String
typealias FontExtension = String
typealias Font = (url: FontPath, name: FontName, ext: FontExtension)

var allLoadedFonts: [Font] = []

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
  class func loadFonts(at url: URL) -> [Font] {
    var loadedFonts: [Font] = []
    do {
      let contents = try FileManager.default.contentsOfDirectory(
        at: url,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
      )

      let alreadyLoaded = allLoadedFonts.map { $0.url }
      for font in fonts(contents) {
        if let idx = alreadyLoaded.index(of: font.url) {
          loadedFonts.append(allLoadedFonts[idx])
        } else if let lf = loadFont(font) {
          loadedFonts.append(lf)
        }
      }
    } catch let error as NSError {
      log("""
      There was an error loading fonts.
      Path: \(url).
      Error: \(error)
      """)
    }
    return loadedFonts
  }

  class func loadFontsFromBundles(at url: URL) -> [Font] {
    var loadedFonts: [Font] = []
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
        loadedFonts += loadFonts(at: item)
      }
    } catch let error as NSError {
      log("""
      There was an error accessing bundle with url.
      Path: \(url).
      Error: \(error)
      """)
    }
    return loadedFonts
  }

  class func loadFont(_ font: Font) -> Font? {
    let fileURL: FontPath = font.url
    let name = font.name
    let ext = font.ext
    var loadedFontName: String?
    var error: Unmanaged<CFError>?
    if let data = try? Data(contentsOf: fileURL) as CFData,
      let dataProvider = CGDataProvider(data: data) {
      workaroundDeadlock()

      let ref = CGFont(dataProvider)

      if CTFontManagerRegisterGraphicsFont(ref!, &error) {
        if let postScriptName = ref?.postScriptName {
          log("Successfully loaded font: '\(postScriptName)'.")
          loadedFontName = String(postScriptName)
        }
      } else if let error = error?.takeRetainedValue() {
        let errorDescription = CFErrorCopyDescription(error)
        log("Failed to load font '\(name)': \(String(describing: errorDescription))")
      }
    } else {
      guard let error = error?.takeRetainedValue() else {
        log("Failed to load font '\(name)'.")
        return nil
      }
      let errorDescription = CFErrorCopyDescription(error)
      log("Failed to load font '\(name)': \(String(describing: errorDescription))")
    }
    if let lfn = loadedFontName {
      return (fileURL, lfn, ext)
    }
    return nil
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
