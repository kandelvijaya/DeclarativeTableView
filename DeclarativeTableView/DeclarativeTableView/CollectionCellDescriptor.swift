//
//  CollectionCellDescriptor.swift
//  DeclarativeTableView
//
//  Created by Vijaya Prakash Kandel on 5/3/19.
//  Copyright © 2019 com.kandelvijaya.declarativeTableView. All rights reserved.
//

import Foundation
import UIKit
import FastDiff

/// Describes a cell item and its interaction
public struct CollectionCellDescriptor<Model: Hashable, CellType: UICollectionViewCell>: Hashable {
    
    public var hashValue: Int {
        return model.hashValue ^ reuseIdentifier.hashValue ^ cellClass.hash()
    }
    
    public static func == (lhs: CollectionCellDescriptor<Model, CellType>, rhs: CollectionCellDescriptor<Model, CellType>) -> Bool {
        return lhs.model == rhs.model &&
            lhs.cellClass == rhs.cellClass &&
            lhs.reuseIdentifier == rhs.reuseIdentifier
    }
    
    
    public let model: Model
    public let reuseIdentifier: String
    public let cellClass: CellType.Type
    public let configure: (CellType) -> Void
    public var onSelect: (() -> Void)? = nil
    public var onPerfromAction: ((ModelAction) -> Void)? = nil
    
    public init(_ model: Model, identifier: String, cellClass: CellType.Type, configure: @escaping ((CellType) -> Void) = {_ in }) {
        self.model = model
        reuseIdentifier = identifier
        self.cellClass = cellClass
        self.configure = configure
    }
    
}


public extension CollectionCellDescriptor {
    
    
    /// produces type erased CollectionCellDescriptor which can then be used
    /// to display different kinds of cells in the same Collection.
    ///
    /// - Returns: CollectionCellDescriptor<AnyHashable>
    func any() -> CollectionCellDescriptor<AnyHashable, UICollectionViewCell> {
        var anyDescriptor = CollectionCellDescriptor<AnyHashable, UICollectionViewCell>(self.model,
                                                                                  identifier: self.reuseIdentifier,
                                                                                  cellClass: self.cellClass,
                                                                                  configure: { cell in
                                                                                    self.configure(cell as! CellType)
        })
        anyDescriptor.onSelect = onSelect
        anyDescriptor.onPerfromAction = onPerfromAction
        return anyDescriptor
    }
    
    /// This is synonymous to `CollectionCellDescriptor<String, SimpleCell> as! CollectionCellDescriptor<String, UITableViewCell>`
    /// Compiler crashes on running the above casting.
    func rightFixed() -> CollectionCellDescriptor<Model, UICollectionViewCell> {
        var rightFixed = CollectionCellDescriptor<Model, UICollectionViewCell>(self.model,
                                                                         identifier: self.reuseIdentifier,
                                                                         cellClass: self.cellClass,
                                                                         configure: { cell in
                                                                            self.configure(cell as! CellType)
        })
        rightFixed.onSelect = onSelect
        rightFixed.onPerfromAction = onPerfromAction
        return rightFixed
    }
    
}




extension CollectionCellDescriptor: Diffable { }

extension CollectionCellDescriptor: CustomStringConvertible {
    
    public var description: String {
        return "CELL \(model.hashValue)"
    }
    
}
