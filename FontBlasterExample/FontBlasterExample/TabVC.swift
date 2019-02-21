// ©2019 Mihai Cristian Tanase. All rights reserved.

import UIKit

class TabVC: UITabBarController {
  @IBAction func didPressB() {
    if let vc = selectedViewController as? BaseVC {
      vc.loadFonts()
    }
  }
}
