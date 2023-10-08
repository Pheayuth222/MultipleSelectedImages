//
//  YPLibrary+LibraryChange.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import Photos

extension YPLibraryVC: PHPhotoLibraryChangeObserver {
    func registerForLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.initialize()
//            if let fetchResult = self.mediaManager.fetchResult {
//                let collectionChanges = changeInstance.changeDetails(for: fetchResult)
//                if collectionChanges != nil {
//                    let collectionView = self.v.collectionView!
//                    if !collectionChanges!.hasIncrementalChanges || collectionChanges!.hasMoves {
//
////                        collectionView.reloadData()
//                        self.initialize()
//                    } else {
//                        collectionView.performBatchUpdates({
//                            let removedIndexes = collectionChanges!.removedIndexes
//                            if (removedIndexes?.count ?? 0) != 0 {
//                                collectionView.deleteItems(at: removedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
//                            }
//                            let insertedIndexes = collectionChanges!.insertedIndexes
//                            if (insertedIndexes?.count ?? 0) != 0 {
//                                collectionView.insertItems(at: insertedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
//                            }
//                        }, completion: { finished in
//                            if finished {
//                                let changedIndexes = collectionChanges!.changedIndexes
//                                if (changedIndexes?.count ?? 0) != 0 {
//                                    collectionView.reloadItems(at: changedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
//                                }
//                            }
//                        })
//                    }
//                    self.mediaManager.resetCachedAssets()
//                }
//            }
//            else {
//                // reload  image selected image done
//                self.initialize()
//            }
            
            
            //dimiss custom alert when seleted photo
            let photoCount = PHAsset.fetchAssets(with: nil).count
            if photoCount > 0 {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
