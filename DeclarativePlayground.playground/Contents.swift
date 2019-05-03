import UIKit
import DeclarativeTableView
import PlaygroundSupport

class ViewController: UIViewController {
    
    private var currentChild: UIViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let models = ["Apple", "Microsoft", "Google", "||Zalando is a company that i work currently at.||"]
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
        
        let combinedSections = [sections.any(), secondSection.any(), mixedSection]
        let list = CollectionViewController(with: combinedSections)
        embed(list)
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

