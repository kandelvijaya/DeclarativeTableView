//
//  GenericCollection<T>.swift
//  DeclarativeTableView
//
//  Created by Vijaya Prakash Kandel on 5/3/19.
//  Copyright © 2019 com.kandelvijaya.declarativeTableView. All rights reserved.
//

import UIKit
import FastDiff
import Kekka

extension DiffOperation.Simple: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .add(_, at):
            return "insert at index \(at)"
        case let .delete(_, at):
            return "delete from index \(at)"
        case let .update(_, _, at):
            return "update item at \(at)"
        }
    }
    
}


/// A generic collection view controller.
/// A collection view can contain different cells in a section and
/// different kinds of sections. This property is acheived by
/// using a type erased CollectionCellDescriptor.
///
/// - note: see `CellDescriptor.any()` for more info
open class CollectionViewController<T: Hashable>: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private(set) var sectionDescriptors: [CollectionSectionDescriptor<T>]
    private let handlers: ListActionHandler
    
    public init(with models: [CollectionSectionDescriptor<T>], layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout(), actionsHandler: ListActionHandler = .empty()) {
        self.sectionDescriptors = models
        self.handlers = actionsHandler
        super.init(collectionViewLayout: layout)
        registerCells(for: models)
        self.collectionView.backgroundColor = .white
    }
    
    private func registerCells(for descriptors: [CollectionSectionDescriptor<T>]) {
        let uniqueCellDescriptors = descriptors.flatMap { section in
            return section.children.map { cell in
                return (cell.cellClass, cell.reuseIdentifier)
            }
        }
        
        uniqueCellDescriptors.forEach {
            collectionView.register($0.0, forCellWithReuseIdentifier: $0.1)
        }
        
    }
    
    
    private func packingDeleteAndUpdateOnSameIndexToUpdateIfUnderlyingModelIsSame<T>(from diffResult:  [DiffOperation<T>.Simple]) -> [DiffOperation<T>.Simple] {
        var accumulated: [DiffOperation<T>.Simple] = []
        var addDeleteMap: [Int: (add: DiffOperation<T>.Simple?, delete: DiffOperation<T>.Simple?)] = [:]
        for index in diffResult {
            if case let .add(_, at) = index {
                let previous = addDeleteMap[at]
                addDeleteMap[at] = (add: index, delete: previous?.delete)
            } else if case let .delete(_, from) = index {
                let previous = addDeleteMap[from]
                addDeleteMap[from] = (add: previous?.add, delete: index)
            }
         }
        
        for aDmapItem in addDeleteMap.sorted(by: { $0.key < $1.key}) {
            let addItem: (T, Int)? = aDmapItem.value.add?.add
            let deleteItem: (T, Int)? = aDmapItem.value.delete?.delete
            switch (addItem, deleteItem) {
            case let (a?, d?):
                let update = DiffOperation<T>.Simple.update(d.0, a.0, aDmapItem.key)
                accumulated.append(update)
            case let (a?, _):
                accumulated.append(DiffOperation<T>.Simple.add(a.0, aDmapItem.key))
            case let (_, d?):
                accumulated.append(DiffOperation<T>.Simple.delete(d.0, aDmapItem.key))
            default:
                break
            }
        }
        
        let allDeletes = accumulated.filter { $0.delete != nil }.sorted(by: { $0.delete!.1 > $1.delete!.1})  // deletes in descending order
        let addAdditions = accumulated.filter { $0.add != nil }
        let updates = accumulated.filter { $0.update != nil }
        return updates + allDeletes + addAdditions
    }
    
    public func orderedOperationWithUpdateFirst<T>(from operations: [DiffOperation<T>]) -> [DiffOperation<T>.Simple] {
        var deletions = [Int: DiffOperation<T>.Simple]()
        var insertions = [DiffOperation<T>.Simple]()
        var updates = [DiffOperation<T>.Simple]()
        
        for oper in operations {
            switch oper {
            case let .update(item, newItem, index):
                updates.append(.update(item, newItem, index))
            case let .add(item, atIndex):
                insertions.append(.add(item, atIndex))
            case let .delete(item, from):
                deletions[from] = .delete(item, from)
            case let .move(item, from, to):
                insertions.append(.add(item, to))
                deletions[from] = .delete(item, from)
            }
        }
        let descendingOrderedIndexDeletions = deletions.sorted(by: {$0.0 > $1.0 }).map{ $0.1 }
        return updates + descendingOrderedIndexDeletions + insertions
    }

    
    open func update(with newModels: [CollectionSectionDescriptor<T>]) {
        registerCells(for: newModels)
        let currentModels = self.sectionDescriptors
        let diffResultTemp = orderedOperationWithUpdateFirst(from: diff(currentModels, newModels))
        
        /// We need to pack Section with delete(aI) and add(aI) as update(old, new, aI)
        /// This is so that the we can maintain the previous state in the Collection +- the change
        let diffResult = packingDeleteAndUpdateOnSameIndexToUpdateIfUnderlyingModelIsSame(from: diffResultTemp)
        
        collectionView.performBatchUpdates({
            self.sectionDescriptors = newModels
            
            /// first diff on deeper level
            let internalEdits = internalDiff(from: diffResult)
            internalEdits.forEach {
                let packed = packingDeleteAndUpdateOnSameIndexToUpdateIfUnderlyingModelIsSame(from: $0.operations)
                performRowChanges(packed, at: $0.offset)
            }
            
            /// extenal diff
            performSectionChanges(diffResult)
        }) { (completed) in
            // Fall back if the batch update fails
            if completed == false {
                self.collectionView.reloadData()
            }
        }
    }
    
    open func performSectionChanges<T>(_ diffSet: [DiffOperation<CollectionSectionDescriptor<T>>.Simple]) {
        diffSet.forEach { item in
            switch item {
            case let .delete(_, fromIndex):
                self.collectionView.deleteSections(IndexSet(integer: fromIndex))
            case let .add(_, atIndex):
                self.collectionView.insertSections(IndexSet(integer: atIndex))
            case .update:
                // This should be handled prior to the section update.
                break
            }
        }
    }
    
    func performRowChanges<T>(_ diffSet: [DiffOperation<CollectionCellDescriptor<T, UICollectionViewCell>>.Simple], at sectionIndex: Int) {
        diffSet.forEach { cellDiffRes in
            switch cellDiffRes {
            case let .delete(_, atIndex):
                print("Delete item at index \(atIndex)")
                self.collectionView.deleteItems(at: [IndexPath(row: atIndex, section: sectionIndex)])
            case let .add(_, idx):
                print("Adding item at index \(idx)")
                self.collectionView.insertItems(at: [IndexPath(item: idx, section: sectionIndex)])
            case let .update(_, _, idx):
                print("Updating item at index \(idx)")
                self.collectionView.reloadItems(at: [IndexPath(item: idx, section: sectionIndex)])
            }
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("initCoder: not implemented")
    }
    
    public func model(at indexPath: IndexPath) -> CollectionCellDescriptor<T, UICollectionViewCell> {
        return self.sectionDescriptors[indexPath.section].items[indexPath.row]
    }
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionDescriptors.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionDescriptors[section].items.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentItem = model(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currentItem.reuseIdentifier, for: indexPath)
        currentItem.configure(cell)
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentItem = model(at: indexPath)
        collectionView.deselectItem(at: indexPath, animated: true)
        currentItem.onSelect?()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handlers.onExit?()
    }
    
}



extension DiffOperation.Simple {
    
    var add: (T, Int)? {
        guard case let .add(v, i) = self else { return nil }
        return (v, i)
    }
    
    var delete: (T, Int)? {
        guard case let .delete(v, i) = self else { return nil }
        return (v, i)
    }
    
    var update: (T, T, Int)? {
        guard case let .update(o, n, i) = self else { return nil }
        return (o, n, i)
    }
}
