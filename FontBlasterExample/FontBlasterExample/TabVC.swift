// ©2019 Mihai Cristian Tanase. All rights reserved.

import UIKit

class TabVC: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func didPressB() {
    if let vc = selectedViewController as? BaseVC {
      vc.loadFonts()
    }
  }
}
