// ©2019 Mihai Cristian Tanase. All rights reserved.

import FontBlaster
import UIKit

class BaseVC: UIViewController,
  UITableViewDelegate, UITableViewDataSource {
  @IBOutlet var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    FontBlaster.debugEnabled = true
  }

  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return fontNames.count
  }

  func tableView(
    _: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "ReuseIdentifier")
    let fontName = fontNames[indexPath.item]
    if let label = cell.textLabel {
      label.text = fontName
      label.font = UIFont(name: fontName, size: label.font.pointSize)
    }
    return cell
  }

  var fontNames: [String] { return [] }
  func loadFonts() {}
}
