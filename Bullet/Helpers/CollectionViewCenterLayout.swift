//
//  CollectionViewCenterLayout.swift
//  CenteredCollectionView-Sample
//
//  Created by Dejan Skledar on 17/04/2018.
//  Copyright © 2018 Dejan Skledar. All rights reserved.
//

import UIKit

class CollectionViewRow {
    var attributes = [UICollectionViewLayoutAttributes]()
    var spacing: CGFloat = 0


    init(spacing: CGFloat) {
        self.spacing = spacing
    }

    func add(attribute: UICollectionViewLayoutAttributes) {
        attributes.append(attribute)
    }

    var rowWidth: CGFloat {
        return attributes.reduce(0, { result, attribute -> CGFloat in
            return result + attribute.frame.width
        }) + CGFloat(attributes.count - 1) * spacing
    }

    func centerLayout(_ collectionViewWidth: CGFloat) {
        let padding = (collectionViewWidth - rowWidth) / 2
        var offset = padding
        for attribute in attributes {
            attribute.frame.origin.x = offset
            offset += attribute.frame.width + spacing
        }
    }
    
    func leftLayout(_ collectionViewWidth: CGFloat) {
        var offset: CGFloat = 10//CGFloat.zero
        
        for attr in attributes {
            attr.frame.origin.x = offset
            offset += attr.frame.width + spacing
        }
    }
    
    func rightLayout(_ collectionViewWidth: CGFloat) {
        var offset = collectionViewWidth - rowWidth
        
        for attr in attributes {
            attr.frame.origin.x = offset
            offset += attr.frame.width + spacing
        }
    }
    
    
}

enum AlignLayout {
    case left
    case right
    case center
}

class UICollectionViewCenterLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        var rows = [CollectionViewRow]()
        var currentRowY: CGFloat = -1

        for attribute in attributes {
            if currentRowY != attribute.frame.midY {
                currentRowY = attribute.frame.midY
                rows.append(CollectionViewRow(spacing: 10))
            }
            rows.last?.add(attribute: attribute)
        }

//        rows.forEach { $0.centerLayout(collectionViewWidth: collectionView?.frame.width ?? 0) }
        rows.forEach { item in
            item.centerLayout(collectionView?.frame.width ?? 0)
        }
        
        return rows.flatMap { $0.attributes }
    }
}


class UICollectionViewLeftLayout: UICollectionViewFlowLayout {
    
    var align = AlignLayout.left
    
    override var collectionViewContentSize: CGSize {
        let size = CGSize(width: (self.collectionView?.frame.size.width ?? 0) * 1.4, height: self.collectionView?.frame.size.height ?? 0)
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        var rows = [CollectionViewRow]()
        var currentRowY: CGFloat = -1

        for attribute in attributes {
            if currentRowY != attribute.frame.midY {
                currentRowY = attribute.frame.midY
                rows.append(CollectionViewRow(spacing: 10))
            }
            rows.last?.add(attribute: attribute)
        }

//        rows.forEach { $0.centerLayout(collectionViewWidth: collectionView?.frame.width ?? 0) }
        rows.forEach { item in
            switch self.align {
            case .center:
                item.centerLayout(collectionView?.frame.width ?? 0)
            case .left:
                item.leftLayout(collectionView?.frame.width ?? 0)
            default:
                item.rightLayout(collectionView?.frame.width ?? 0)
            }
        }
        
        return rows.flatMap { $0.attributes }
    }
}

