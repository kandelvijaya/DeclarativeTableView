//
//  ListItemDescriptor.swift
//  DeclarativeTableView
//
//  Created by Vijaya Prakash Kandel on 21.03.19.
//  Copyright © 2019 com.kandelvijaya.declarativeTableView. All rights reserved.
//

import Foundation
import UIKit
import FastDiff

/// Describes a cell item and its interaction
public struct ListCellDescriptor<Model: Hashable, CellType: UITableViewCell>: Hashable {

    public var hashValue: Int {
        return model.hashValue ^ reuseIdentifier.hashValue ^ cellClass.hash()
    }

    public static func == (lhs: ListCellDescriptor<Model, CellType>, rhs: ListCellDescriptor<Model, CellType>) -> Bool {
        return lhs.model == rhs.model &&
            lhs.cellClass == rhs.cellClass &&
            lhs.reuseIdentifier == rhs.reuseIdentifier
    }


    public let model: Model
    public let reuseIdentifier: String
    public let cellClass: CellType.Type
    public let configure: (CellType) -> Void
    public var onSelect: (() -> Void)? = nil
    public var onPerfromAction: ((Model) -> Void)? = nil

    public init(_ model: Model, identifier: String, cellClass: CellType.Type, configure: @escaping ((CellType) -> Void) = {_ in }) {
        self.model = model
        reuseIdentifier = identifier
        self.cellClass = cellClass
        self.configure = configure
    }

}


public extension ListCellDescriptor {


    /// produces type erased ListCellDescriptor which can then be used
    /// to display different kinds of cells in the same list.
    ///
    /// - Returns: ListCellDescriptor<AnyHashable>
    public func any() -> ListCellDescriptor<AnyHashable, UITableViewCell> {
        var anyDescriptor = ListCellDescriptor<AnyHashable, UITableViewCell>(self.model,
                                                                             identifier: self.reuseIdentifier,
                                                                             cellClass: self.cellClass,
                                                                             configure: { cell in
                                                                                self.configure(cell as! CellType)
        })
        anyDescriptor.onSelect = onSelect
        anyDescriptor.onPerfromAction = onPerfromAction as? ((AnyHashable) -> Void)
        return anyDescriptor
    }

}


extension ListCellDescriptor: Diffable { }

extension ListCellDescriptor: CustomStringConvertible {

    public var description: String {
        return "CELL \(model.hashValue)"
    }

}
