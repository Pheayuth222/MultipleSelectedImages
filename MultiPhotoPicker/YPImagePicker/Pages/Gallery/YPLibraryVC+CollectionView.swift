//
//  YPLibraryVC+CollectionView.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

extension YPLibraryVC {
    var isLimitExceeded: Bool { return selectionArr.count >= YPConfig.library.maxNumberOfItems }
    
    func setupCollectionView() {
        v.collectionView.dataSource = self
        v.collectionView.delegate   = self
        v.collectionView.register(YPLibraryViewCell.self, forCellWithReuseIdentifier: "YPLibraryViewCell")
        v.collectionView.layer.cornerRadius = 10
        v.collectionView.clipsToBounds      = true
        
        // Long press on cell to enable multiple selection
//        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
//        longPressGR.minimumPressDuration = 0.5
//        v.collectionView.addGestureRecognizer(longPressGR)
    }
    
    /// When tapping on the cell with long press, clear all previously selected cells.
    @objc func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if multipleSelectionEnabled || isProcessing || YPConfig.library.maxNumberOfItems <= 1 {
            return
        }
        
        if longPressGR.state == .began {
            let point = longPressGR.location(in: v.collectionView)
            guard let indexPath = v.collectionView.indexPathForItem(at: point) else {
                return
            }
            startMultipleSelection(at: IndexPath(item: indexPath.row - 1, section: indexPath.section)) //edit
        }
    }
    
    func startMultipleSelection(at indexPath: IndexPath) {
        currentlySelectedIndex = indexPath.row
        multipleSelectionButtonTapped()
        
        // Update preview.
        changeAsset(mediaManager.fetchResult[indexPath.row])
        
        // Bring preview down and keep selected cell visible.
        panGestureHelper.resetToOriginalState()
        if !panGestureHelper.isImageShown {
            v.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        v.refreshImageCurtainAlpha()
    }
    
    // MARK: - Library collection view cell managing
    
    /// Removes cell from selection
    func deselect(indexPath: IndexPath) {
        if let positionIndex = selectionArr.firstIndex(where: {
            $0.assetIdentifier == mediaManager.fetchResult[indexPath.row].localIdentifier
        }) {
            selectionArr.remove(at: positionIndex)

            // Refresh the numbers
            var selectedIndexPaths = [IndexPath]()
            mediaManager.fetchResult.enumerateObjects { [unowned self] (asset, index, _) in
                if self.selectionArr.contains(where: { $0.assetIdentifier == asset.localIdentifier }) {
                    selectedIndexPaths.append(IndexPath(row: index, section: 0))
                }
            }
//            v.collectionView.reloadItems(at: selectedIndexPaths)
            // Replace the current selected image with the previously selected one
            if let previouslySelectedIndexPath = selectedIndexPaths.last {
                v.collectionView.deselectItem(at: indexPath, animated: true)
                v.collectionView.selectItem(at: previouslySelectedIndexPath, animated: true, scrollPosition: [])
//                currentlySelectedIndex = previouslySelectedIndexPath.row
                if indexPath.row != 0 {
                    changeAsset(mediaManager.fetchResult[previouslySelectedIndexPath.row])
                }            }
            if indexPath.row != 0 {
                v.collectionView.reloadData()
            }
            checkLimit()
        }
    }
    
    /// Adds cell to selection
    func addToSelection(indexPath: IndexPath) {
        if !(delegate?.libraryViewShouldAddToSelection(indexPath: indexPath, numSelections: selectionArr.count) ?? true) {
            return
        }
        
        // Prevent index out of range
        var index = indexPath.item
        
        if mediaManager.fetchResult.count == indexPath.item {
            index -= 1
        }
        
        let asset = mediaManager.fetchResult[index]
        selectionArr.append(
            YPLibrarySelection(
                index: indexPath.row,
                assetIdentifier: asset.localIdentifier
            )
        )
        checkLimit()
    }
    
    func isInSelectionPool(indexPath: IndexPath) -> Bool {
        return selectionArr.contains(where: {
            $0.assetIdentifier == mediaManager.fetchResult[indexPath.row].localIdentifier
        })
    }
    
    /// Checks if there can be selected more items. If no - present warning.
    func checkLimit() {
        v.maxNumberWarningView.isHidden = !isLimitExceeded || multipleSelectionEnabled == false
    }
    
    func showPermissionAlert() {
        self.alertYesNo(
            title   : #""WABooK" Would Like to Access the Camera"#,
            message : "메모 등록시 사진첨부를 위해서 카메라 접근을 승인해야 합니다.",
            nobtn   : "Don't Allow",
            yesbtn  : "ok",
            completion: { (ok) in
                if ok {
                    self.gotoAppSettings()
                }
            })
    }
    
    private func checkCameraPermisson( ) {
        self.checkAllowCameraPermission(completion: { (allow) in
            if allow {
                self.openCameraVC()
            }
            else {
                self.showPermissionAlert()
            }
        })
        
    }
    func openCameraVC(){
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let vc = self.VC(sbName: "CameraSB", identifier: "CameraVC") as! CameraVC
                self.pushVC(viewController: vc, animated: true)
            }
        }
    }
    
}

extension YPLibraryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // + 1 because add camera to to collection
    // - 1 get the current selected image
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaManager.fetchResult.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YPLibraryViewCell",
                                                            for: indexPath) as? YPLibraryViewCell else {
            fatalError("unexpected cell in collection view")
        }
        
        //        open camera on first
        if indexPath.row == 0 {
            cell.imageView.image                            = UIImage(named: "camera_image")
            cell.multipleSelectionIndicator.isHidden        = true
            cell.isSelected                                 = false
            cell.selectionOverlay.alpha                     = 0
            return cell
        }else {
            let asset                                       = mediaManager.fetchResult[indexPath.item - 1]  //edit
            cell.representedAssetIdentifier                 = asset.localIdentifier
            cell.multipleSelectionIndicator.isHidden        = false
            cell.representedAssetIdentifier                 = asset.localIdentifier
            cell.multipleSelectionIndicator.selectionColor  = YPConfig.colors.multipleItemsSelectedCircleColor
            ?? YPConfig.colors.tintColor
            
            mediaManager.imageManager?.requestImage(for: asset,
                                                    targetSize: v.cellSize(),
                                                    contentMode: .aspectFill,
                                                    options: nil) { image, _ in
                // The cell may have been recycled when the time this gets called
                // set image only if it's still showing the same asset.
                if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                    if indexPath.row != 0 {
                        cell.imageView.image = image
                    }
                }
            }
            
            let isVideo = (asset.mediaType == .video)
            cell.durationLabel.isHidden = !isVideo
            cell.durationLabel.text = isVideo ? YPHelper.formattedStrigFrom(asset.duration) : ""
    //        cell.multipleSelectionIndicator.isHidden = !multipleSelectionEnabled  // hidden show multi select image indicator
            cell.isSelected = currentlySelectedIndex == indexPath.row //set highlighted image
            
            // Set correct selection number
            if let index = selectionArr.firstIndex(where: { $0.assetIdentifier == asset.localIdentifier }) {
                let currentSelection = selectionArr[index]
                if currentSelection.index < 0 {
                    selectionArr[index] = YPLibrarySelection(index: indexPath.row - 1, //edit
                                                          cropRect: currentSelection.cropRect,
                                                          scrollViewContentOffset: currentSelection.scrollViewContentOffset,
                                                          scrollViewZoomScale: currentSelection.scrollViewZoomScale,
                                                          assetIdentifier: currentSelection.assetIdentifier)
                }
                cell.multipleSelectionIndicator.set(number: index + 1) // start at 1, not 0
                cell.selectionOverlay.alpha = indexPath.row == 0 ? 0 : 0.6 //set highlighted image
            } else {
                cell.multipleSelectionIndicator.set(number: nil)
                cell.selectionOverlay.alpha = 0
            }
            
            // Prevent weird animation where thumbnail fills cell on first scrolls.
            UIView.performWithoutAnimation {
                cell.layoutIfNeeded()
            }
            return cell
        }
    }
    
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            self.checkCameraPermisson()
        }else{
            let previouslySelectedIndexPath = IndexPath(row: currentlySelectedIndex, section: 0)
            currentlySelectedIndex = indexPath.row

            changeAsset(mediaManager.fetchResult[indexPath.row - 1])
//            panGestureHelper.resetToOriginalState() //pull to top display large image when selected image
            
            // Only scroll cell to top if preview is hidden.
            if !panGestureHelper.isImageShown {
                collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
            v.refreshImageCurtainAlpha()
                
            if multipleSelectionEnabled {
                let cellIsInTheSelectionPool = isInSelectionPool(indexPath: IndexPath(item: indexPath.row - 1, section: indexPath.section)) //edit
                if cellIsInTheSelectionPool {
                    
                    //double select on image unSelect
//                    if cellIsCurrentlySelected {
//                        deselect(indexPath: IndexPath(item: indexPath.row - 1, section: indexPath.section)) //edit
//                    }
                    
                    // deselect image
                    deselect(indexPath: IndexPath(item: indexPath.row - 1, section: indexPath.section))
                    
                } else if isLimitExceeded == false {
                    addToSelection(indexPath: IndexPath(item: indexPath.row - 1, section: indexPath.section))
                }
                collectionView.reloadItems(at: [indexPath])
//                collectionView.reloadItems(at: [previouslySelectedIndexPath])
                
            } else {
                selectionArr.removeAll()
                addToSelection(indexPath: IndexPath(item: indexPath.row - 1, section: indexPath.section))
                
                // Force deseletion of previously selected cell.
                // In the case where the previous cell was loaded from iCloud, a new image was fetched
                // which triggered photoLibraryDidChange() and reloadItems() which breaks selection.
                //
                if let previousCell = collectionView.cellForItem(at: previouslySelectedIndexPath) as? YPLibraryViewCell {
                    previousCell.isSelected = false
                }
            }
        }
    }
}

extension YPLibraryVC : UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return isProcessing == false
    }
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return isProcessing == false
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    //--------------------------------------------------------------------------------

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    //--------------------------------------------------------------------------------

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.frame.size.width / 4) - 2,height: (collectionView.frame.size.width / 4) - 2)
    }

    //--------------------------------------------------------------------------------

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
}

extension UICollectionView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
