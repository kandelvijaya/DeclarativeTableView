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


/// A generic collection view controller.
/// A collection view can contain different cells in a section and
/// different kinds of sections. This property is acheived by
/// using a type erased CollectionCellDescriptor.
///
/// - note: see `CellDescriptor.any()` for more info
open class CollectionViewController<T: Hashable>: UICollectionViewController {
    
    private(set) var sectionDescriptors: [CollectionSectionDescriptor<T>]
    private let handlers: ListActionHandler
    
    public init(with models: [CollectionSectionDescriptor<T>], layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout(), actionsHandler: ListActionHandler = .empty()) {
        self.sectionDescriptors = models
        self.handlers = actionsHandler
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
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
    
    private func packingConsequetiveDeleteAddWithUpdate<T>(from diffResult:  [DiffOperation<T>]) -> [DiffOperation<T>] {
        if diffResult.isEmpty { return [] }
        
        var currentSeekIndex = 0 // This is the index that is not processed.
        
        var accumulator: [DiffOperation<T>] = []
        while currentSeekIndex < diffResult.count {
            let thisItem = diffResult[currentSeekIndex]
            let nextIndex = currentSeekIndex.advanced(by: 1)
            
            if nextIndex < diffResult.count {
                let nextItem = diffResult[nextIndex]
                switch (thisItem, nextItem) {
                case let (.delete(di, dIndex), .add(ai, aIndex)) where dIndex == aIndex:
                    let update = DiffOperation<T>.update(di, ai, dIndex)
                    accumulator.append(update)
                default:
                    accumulator.append(thisItem)
                    accumulator.append(nextItem)
                }
                currentSeekIndex = nextIndex.advanced(by: 1)
            } else {
                // This is the last item
                accumulator.append(thisItem)
                // This breaks the iteration
                currentSeekIndex = nextIndex
            }
        }
        return accumulator
    }
    
    open func update(with newModels: [CollectionSectionDescriptor<T>]) {
        registerCells(for: newModels)
        let currentModels = self.sectionDescriptors
        let diffResultTemp = orderedOperationWithMove(from: diff(currentModels, newModels))
        
        /// We need to pack Section with delete(aI) and add(aI) as update(old, new, aI)
        /// This is so that the we can maintain the previous state in the Collection +- the change
        let diffResult = packingConsequetiveDeleteAddWithUpdate(from: diffResultTemp)
        
        collectionView.performBatchUpdates({
            self.sectionDescriptors = newModels
            
            /// first diff on deeper level
            let internalEdits = internalDiffHere(from: diffResult)
            internalEdits.forEach { performRowChanges($0.operations, at: $0.offset) }
            
            /// extenal diff
            performSectionChanges(diffResult)
        }) { (completed) in
            // Fall back if the batch update fails
            if completed == false {
                self.collectionView.reloadData()
            }
        }
    }
    
    public func internalDiffHere<T: Diffable>(from diffOperations: [DiffOperation<T>]) -> [(offset: Int, operations: [DiffOperation<T.InternalItemType>])] {
        var accumulator = [(offset: Int, operations: [DiffOperation<T.InternalItemType>])]()
        for operation in diffOperations {
            switch operation {
            case let .update(oldContainer, newContainer, atIndex):
                let oldChildItems = oldContainer.children
                let newChildItems = newContainer.children
                let internalDiff = orderedOperationWithMove(from: diff(oldChildItems, newChildItems))
                let output = (atIndex, internalDiff)
                accumulator.append(output)
            default:
                break
            }
        }
        return accumulator
    }

    
    public func orderedOperationWithMove<T>(from operations: [DiffOperation<T>]) -> [DiffOperation<T>] {
        /// Deletions need to happen from higher index to lower (to avoid corrupted indexes)
        ///  [x, y, z] will be corrupt if we attempt [d(0), d(2), d(1)]
        ///  d(0) succeeds then array is [x,y]. Attempting to delete at index 2 produces out of bounds error.
        /// Therefore we sort in descending order of index
        var deletions = [Int: DiffOperation<T>]()
        var insertions = [DiffOperation<T>]()
        var moves = [DiffOperation<T>]()
        var updates = [DiffOperation<T>]()
        
        for oper in operations {
            switch oper {
            case .update:
                updates.append(oper)
            case let .add(item, atIndex):
                insertions.append(.add(item, atIndex))
            case let .delete(item, from):
                deletions[from] = .delete(item, from)
            case .move:
                moves.append(oper)
            }
        }
        let descendingOrderedIndexDeletions = deletions.sorted(by: {$0.0 > $1.0 }).map{ $0.1 }
        return descendingOrderedIndexDeletions + insertions + updates + moves
    }

    
    open func performSectionChanges<T>(_ diffSet: [DiffOperation<CollectionSectionDescriptor<T>>]) {
        diffSet.forEach { item in
            switch item {
            case let .delete(_, fromIndex):
                self.collectionView.deleteSections(IndexSet(integer: fromIndex))
            case let .add(_, atIndex):
                self.collectionView.insertSections(IndexSet(integer: atIndex))
            case let .move(_, from, to):
                self.collectionView.moveSection(from, toSection: to)
            case .update:
                // This should be handled prior to the section update.
                break
            }
        }
    }
    
    func performRowChanges<T>(_ diffSet: [DiffOperation<CollectionCellDescriptor<T, UICollectionViewCell>>], at sectionIndex: Int) {
        diffSet.forEach { cellDiffRes in
            switch cellDiffRes {
            case let .delete(_, atIndex):
                self.collectionView.deleteItems(at: [IndexPath(row: atIndex, section: sectionIndex)])
            case let .add(_, idx):
                self.collectionView.insertItems(at: [IndexPath(item: idx, section: sectionIndex)])
            case let .move(_, from, to):
                self.collectionView.moveItem(at: IndexPath(item: from, section: sectionIndex), to: IndexPath(item: to, section: sectionIndex))
            default:
                break
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

