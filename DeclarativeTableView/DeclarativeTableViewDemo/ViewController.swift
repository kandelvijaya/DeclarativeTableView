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
        
        
        let models = ["Apple", "Microsoft", "Google"]
        
        let identifier = "MyCell"

        let cellDescs  = models.map { m -> ListCellDescriptor<String, SimpleCell> in
            var cd = ListCellDescriptor(m, identifier: identifier, cellClass: SimpleCell.self, configure: { cell in
                cell.textLabel?.text = m
            })
            cd.onSelect = { [weak self] in
                self?.tapped(m)
            }
            return cd
        }

        let sections = ListSectionDescriptor(with: cellDescs)
        let list = ListViewController(with: [sections])
        embed(list)
    }

    func tapped(_ item: String) {
        let thisModels = [1,2,3]
        let cellDescs = thisModels.map { item in
            return ListCellDescriptor(item, identifier: "Inner", cellClass: SimpleCell.self, configure: { cell in
                cell.textLabel?.text = "\(item)"
            })
        }
        let sectionDesc = ListSectionDescriptor(with: cellDescs)
        let list = ListViewController(with: [sectionDesc])
        self.show(list, sender: self)
    }

    func embed(_ vc: UIViewController) {
        self.currentChild = vc
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        [
            vc.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            vc.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            vc.view.leftAnchor.constraint(equalTo: view.leftAnchor)
            ].forEach { $0.isActive = true }
        vc.didMove(toParent: self)
    }

    func removeChild() {
        self.currentChild?.willMove(toParent: nil)
        self.currentChild?.view.removeFromSuperview()
        self.currentChild?.removeFromParent()
    }

}

class SimpleCell: UITableViewCell { }
