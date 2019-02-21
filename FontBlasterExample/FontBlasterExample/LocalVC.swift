// ©2019 Mihai Cristian Tanase. All rights reserved.

import FontBlaster
import UIKit

final class LocalVC: BaseVC {
  private lazy var _fontNames = [
    "Mew Too Hand",
    "Mew Too Hand Bold",
    "Mew Too Hand Bold Condensed",
    "Mew Too Hand Bold Condensed Italic",
    "Mew Too Hand Bold Condensed Lta",
    "Mew Too Hand Bold Italic",
    "Mew Too Hand Bold Lta",
    "Mew Too Hand Bold Wide",
    "Mew Too Hand Bold Wide Italic",
    "Mew Too Hand Bold Wide Lta",
    "Mew Too Hand Condensed",
    "Mew Too Hand Condensed Italic",
    "Mew Too Hand Condensed Lta",
    "Mew Too Hand Extra Italic",
    "Mew Too Hand Italic",
    "Mew Too Hand Lta",
    "Mew Too Hand Reversed",
    "Mew Too Hand Reversed Italic",
    "Mew Too Hand Ultimate Condensed Italic",
    "Mew Too Hand Ultimate Italic",
    "Mew Too Hand Ultimate Italic Wide",
    "Mew Too Hand Ultra Italic",
    "Mew Too Hand Wide",
    "Mew Too Hand Wide Italic",
    "Mew Too Hand Wide Lta",
  ]

  override var fontNames: [String] { return _fontNames }

  override func loadFonts() {
    let url = Bundle.main.resourceURL!.appendingPathComponent("KineticPlasma/")
    FontBlaster.blast(at: url) { fonts -> Void in
      print("Loaded Fonts", fonts)
      self._fontNames = fonts.sorted()
      self.tableView.reloadSections([0], with: .automatic)
    }
  }
}
