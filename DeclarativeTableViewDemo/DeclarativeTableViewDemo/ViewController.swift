//
//  ViewController.swift
//  DeclarativeTableViewDemo
//
//  Created by Vijaya Prakash Kandel on 21.03.19.
//  Copyright © 2019 com.kandelvijaya.declarativeTableView. All rights reserved.
//

import UIKit
import DeclarativeTableView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        let models = [1,2,3]
        let identifier = "MCell"

        let cellDescs = models.map { m in
            ListCellDescriptor(m, identifier: identifier, cellClass: SimpleCell.self, configure: { cell in
                cell.textLabel?.text = String(describing: m)
            }).any()
        }

        let sections = ListSectionDescriptor(with: cellDescs)
        let list = ListViewController(with: [sections])
        embed(list)
    }

    func embed(_ vc: UIViewController) {
        vc.willMove(toParent: self)
        self.view.addSubview(vc.view)
        vc.view.bounds = self.view.bounds
        vc.didMove(toParent: self)
    }


}

class SimpleCell: UITableViewCell { }
