//
//  ListCollectionViewFlowLayout.swift
//  Newsic
//
//  Created by Miguel Alcantara on 31/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation
import UIKit

class ListCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var mostRecentOffset : CGPoint = CGPoint()
    var insertingIndexPaths = [IndexPath]()
    var deletingIndexPaths = [IndexPath]()

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        insertingIndexPaths.removeAll()
        deletingIndexPaths.removeAll()
        
        for update in updateItems {
            if let indexPath = update.indexPathAfterUpdate, update.updateAction == .insert {
                insertingIndexPaths.append(indexPath)
            } else if let indexPath = update.indexPathBeforeUpdate, update.updateAction == .delete {
                deletingIndexPaths.append(indexPath)
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        insertingIndexPaths.removeAll()
        deletingIndexPaths.removeAll()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        if insertingIndexPaths.contains(itemIndexPath) {
            attributes?.alpha = 0.0
            attributes?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        
        if deletingIndexPaths.contains(itemIndexPath) {
            attributes?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            attributes?.alpha = 1.0
        }
        
        return attributes
        
    }
}
