//
//  CategoryViewModel.swift
//  IOS News App
//
//  Created by Fabien Maurice on 31/10/2019.
//  Copyright © 2019 Fabien Maurice. All rights reserved.
//

import Foundation
import UIKit
import CollectionView

class CategoryViewModel: ViewModel<CategoryCell, CategoryModel> {

    override func updateView() {
        self.view?.textLabel.text = self.model.name
        self.view?.imageView.image = UIImage(named: self.model.image)
    }

    override func size(grid: Grid) -> CGSize {
        if
            (self.collectionView.traitCollection.userInterfaceIdiom == .phone &&
             self.collectionView.traitCollection.verticalSizeClass == .compact) ||
            self.collectionView?.traitCollection.userInterfaceIdiom == .pad
        {
            return grid.size(for: self.collectionView, ratio: 1.2, items: grid.columns / 4, gaps: grid.columns - 1)
        }
        if grid.columns == 1 {
            return grid.size(for: self.collectionView, ratio: 1.1)
        }
        return grid.size(for: self.collectionView, ratio: 1.2, items: grid.columns / 2, gaps: grid.columns - 1)
    }

}
