// ©2019 Mihai Cristian Tanase. All rights reserved.

import FontBlaster
import UIKit

final class BundleVC: BaseVC {
  private lazy var _fontNames = [
    "OpenSans",
    "OpenSans-Bold",
    "OpenSans-BoldItalic",
    "OpenSans-Extrabold",
    "OpenSans-ExtraboldItalic",
    "OpenSans-Italic",
    "OpenSans-Light",
    "OpenSans-Semibold",
    "OpenSans-SemiboldItalic",
    "OpenSansLight-Italic",
  ]

  override var fontNames: [String] { return _fontNames }

  override func loadFonts() {
    FontBlaster.blast { fonts -> Void in
      print("Loaded Fonts", fonts)
      self._fontNames = fonts.sorted()
      self.tableView.reloadSections([0], with: .automatic)
    }
  }
}
