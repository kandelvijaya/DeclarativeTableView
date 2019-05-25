//
//  ViewController.swift
//  DeclarativeTableViewDemo
//
//  Created by Vijaya Prakash Kandel on 21.03.19.
//  Copyright © 2019 com.kandelvijaya.declarativeTableView. All rights reserved.
//

import UIKit
import DeclarativeTableView

class ModelItem {
    var title: String = ""
    var name: String = ""
    var age: Int = 0
}


class ViewController: UIViewController {
    
    private var currentChild: UIViewController?
    var list: ListViewController<AnyHashable>!
    
    var model = ModelItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        list = ListViewController.init(with: [])
        embed(list)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cell1 = ListCellDescriptor.init(model.age, identifier: "age", cellClass: EditingCell.self) { cell in
            cell.textField.text = "\(self.model.age)"
            cell.onEdit = { text in self.model.age = Int(text) ?? self.model.age }
        }
        
        
    }
    
    
    func embed(_ vc: UIViewController) {
        self.currentChild = vc
        self.addChild(vc)
        vc.view.frame = view.bounds
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
}


class EditingCell: UITableViewCell {
    
    var textField: UITextField!
    var onEdit: ((String) -> Void)!
    
}



class ViewController2: UIViewController {

    private var currentChild: UIViewController?
    
    var list: CollectionViewController<AnyHashable>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        list = CollectionViewController(with: [], layout: OrgLayout())
        embed(list)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fireIteratively()
    }
    
    private func fireIteratively() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let newModels = self.modelSections()
            self.list.update(with: newModels)
//        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.fireIteratively()
        }
    }
    
    var current: [String] = []
    private func modelSections() -> [CollectionSectionDescriptor<AnyHashable>]{
        let mdls = ["Apple", "Microsoft", "Google", "||Zalando is a company that i work currently at.||", "There was mine", "And docs"]
        
//        var models = mdls.shuffled()
//        models.removeLast(2)
        
        let models1 = ["Apple"]
        let models2 = ["Apple 2", "--> Microsoft"]
        let models = models1 == current ? models2 : models1
        current = models
        let identifier = "MyCell"
        
        let cellDescs  = models.map { m -> CollectionCellDescriptor<String, SimpleCell> in
            var cd = CollectionCellDescriptor(m, identifier: identifier, cellClass: SimpleCell.self, configure: { cell in
                cell.textLabel?.text = m
            })
            cd.onSelect = { [weak self] in
                self?.tapped(m)
            }
            return cd
        }
        
        let sections = CollectionSectionDescriptor(with: cellDescs)
        
        
        let modelsForNextSection = [ModelItem(color: .red, int: 1), .init(color: .blue, int: 2), .init(color: .purple, int: 3)]
        let identifier2 = "IntCell"
        let cellDescs2 = modelsForNextSection.map { m in
            return CollectionCellDescriptor(m, identifier: identifier2, cellClass: SimpleCell.self, configure: { cell in
                cell.textLabel?.text = "\(m.int)"
                cell.backgroundColor = m.color
            })
        }
        
        let secondSection = CollectionSectionDescriptor(with: cellDescs2)
        
        
        let mc1 = CollectionCellDescriptor(1, identifier: "mc1", cellClass: SimpleCell.self, configure: { cell in
            cell.textLabel?.text = "\(1)"
        })
        
        let mc2 = CollectionCellDescriptor("hello", identifier: "mc2", cellClass: AnotherCell.self, configure: { cell in
            cell.textLabel?.text = "hello"
            cell.backgroundColor = .purple
        })
        
        let mixedSection = CollectionSectionDescriptor(with: [mc1.any(), mc2.any()])
        
        var combinedSections = [sections.any(), secondSection.any(), mixedSection]
        return combinedSections
    }
    
    struct ModelItem: Hashable {
        let color: UIColor
        let int: Int
    }

    func tapped(_ item: String) {
        let thisModels = [1,2,3]
        let cellDescs = thisModels.map { item in
            return CollectionCellDescriptor(item, identifier: "Inner", cellClass: SimpleCell.self, configure: { cell in
                cell.textLabel?.text = "\(item)"
            })
        }
        let sectionDesc = CollectionSectionDescriptor(with: cellDescs)
        let list = CollectionViewController(with: [sectionDesc])
        self.show(list, sender: self)
    }

    func embed(_ vc: UIViewController) {
        self.currentChild = vc
        self.addChild(vc)
        vc.view.frame = view.bounds
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }

    func removeChild() {
        self.currentChild?.willMove(toParent: nil)
        self.currentChild?.view.removeFromSuperview()
        self.currentChild?.removeFromParent()
    }

}

class SimpleCell: UICollectionViewCell {
    
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    func setupLabel() {
        textLabel = UILabel()
        self.contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        [
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ].forEach { $0.isActive = true }
    }
    
}

class AnotherCell: SimpleCell {
}


class OrgLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.estimatedItemSize = CGSize(width: 1, height: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let original = super.layoutAttributesForItem(at: indexPath) else { return nil }
        let oldFrame = original.frame
        let newFrame = CGRect(x: 0, y: lastY + lastHeight, width: oldFrame.width, height: oldFrame.height)
        lastY = newFrame.origin.y
        lastHeight = oldFrame.height
        original.frame = newFrame
        return original
    }
    
    var lastY: CGFloat = 0
    var lastHeight:CGFloat = 0
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let original = super.layoutAttributesForElements(in: rect) else { return nil }
        lastY = 0
        lastHeight = 0
        let new = original.compactMap { self.layoutAttributesForItem(at: $0.indexPath) }
        return new
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let original = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        return original
    }
    
    override func prepare() {
        super.prepare()
    }
    
}
