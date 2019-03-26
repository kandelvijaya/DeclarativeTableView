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

    private var currentChild: UIViewController?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let models = ["Simple", "Multi Section", "Multi Section Heterogeneous"]
        let identifier = "MCell"

        let cellDescs = models.map { m in
            ListCellDescriptor(m, identifier: identifier, cellClass: SimpleCell.self, configure: { cell in
                cell.textLabel?.text = m
            }).any()
        }

        let sections = ListSectionDescriptor(with: cellDescs)
        let list = ListViewController(with: [sections])
        embed(list)
    }

    func embed(_ vc: UIViewController) {
        self.currentChild = vc
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.view.bounds = self.view.bounds
        vc.didMove(toParent: self)
    }

    func removeChild() {
        self.currentChild?.willMove(toParent: nil)
        self.currentChild?.view.removeFromSuperview()
        self.currentChild?.removeFromParent()
    }


}

class SimpleCell: UITableViewCell { }