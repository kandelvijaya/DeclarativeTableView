//
//  CollectionSectionDescriptor.swift
//  DeclarativeTableView
//
//  Created by Vijaya Prakash Kandel on 5/3/19.
//  Copyright © 2019 com.kandelvijaya.declarativeTableView. All rights reserved.
//

import Foundation

import UIKit
import FastDiff

/// Describes a Collection section.
public struct CollectionSectionDescriptor<T: Hashable>: Hashable {
    
    //TODO: Why does [CollectionCellDescriptor<T, UITableViewCell>] not have default hashValue
    public var hashValue: Int {
        guard let first = items.first else {
            return 0
        }
        var acc = first.hashValue
        let others = Array(items.dropFirst())
        for thisOne in others {
            let accCopy = acc
            acc = accCopy ^ thisOne.hashValue
        }
        let hash = footerText.map { acc ^ $0.hashValue } ?? acc
        return hash
    }
    
    public let items: [CollectionCellDescriptor<T, UICollectionViewCell>]
    public let footerText: String? = nil
    public let identifier: Int
    
}

extension CollectionSectionDescriptor {
    
    public init<U>(with items: [CollectionCellDescriptor<T, U>]) where U: UICollectionViewCell {
        let intItems = items.map { $0.rightFixed() }
        self.items = intItems
        self.identifier = 0
    }
    
}


public extension CollectionSectionDescriptor {
    
    /// Copies metaData from existing `sectionDescriptor` to produce `newSectionDescriptors`
    func insertReplacing(newItems: [CollectionCellDescriptor<T, UICollectionViewCell>]) -> CollectionSectionDescriptor {
        return CollectionSectionDescriptor(items: newItems, identifier: self.identifier)
    }
    
    /// Copies metaData from existing `sectionDescriptor` to produce `newSectionDescriptors`
    func insertReplacing(new: CollectionSectionDescriptor) -> CollectionSectionDescriptor {
        return CollectionSectionDescriptor(items: new.items, identifier: self.identifier)
    }
    
}

extension CollectionSectionDescriptor: Diffable {
    
    public typealias InternalItemType = CollectionCellDescriptor<T, UICollectionViewCell>
    
    public var diffHash: Int {
        return items.diffHash
    }
    
    public var children: [CollectionCellDescriptor<T, UICollectionViewCell>] {
        return items
    }
    
}

extension CollectionSectionDescriptor: CustomStringConvertible {
    
    public var description: String {
        return "SEC { \(items) }"
    }
    
}


extension CollectionSectionDescriptor {
    
    /// converts a typed section into untyped section
    /// useful to have erased type when creating heterogeneous Collection
    public func any() -> CollectionSectionDescriptor<AnyHashable> {
        let items = self.items.map { $0.any() }
        let section = CollectionSectionDescriptor<AnyHashable>.init(items: items, identifier: self.identifier)
        return section
    }
    
}
