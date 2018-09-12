//
//  TableViewController.swift
//  FontBlasterExample
//
//  Created by Marcelino Alberdi Pereira on 12/09/2018.
//  Copyright © 2018 Marcelino Alberdi Pereira. All rights reserved.
//

import UIKit
import FontBlaster

class TableViewController: UITableViewController {
    private var fontNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        FontBlaster.debugEnabled = true
        FontBlaster.blast { fonts -> Void in
            print("Loaded Fonts", fonts)
            self.fontNames = fonts.sorted()
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ReuseIdentifier")
        let fontName = fontNames[indexPath.item]
        cell.textLabel?.text = fontName
        cell.textLabel?.font = UIFont(name: fontName, size: 20)
        return cell
    }
}
