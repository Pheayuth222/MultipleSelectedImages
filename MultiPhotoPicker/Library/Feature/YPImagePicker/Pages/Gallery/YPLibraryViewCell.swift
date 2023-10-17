////
////  YPLibraryViewCell.swift
////  YPImgePicker
////
////  Created by Sacha Durand Saint Omer on 2015/11/14.
////  Copyright © 2015 Yummypets. All rights reserved.
////
//
//import UIKit
//import Stevia
//
//class YPMultipleSelectionIndicator: UIView {
//
//    let circle = UIView()
//    let label = UILabel()
//    var selectionColor = UIColor.black
//
//    convenience init() {
//        self.init(frame: .zero)
//
//        let size: CGFloat = 20
//
//        sv(
//            circle,
//            label
//        )
//
//        circle.fillContainer()
//        circle.size(size)
//        label.fillContainer()
//
//        circle.layer.cornerRadius = size / 2.0
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//
//        set(number: nil)
//    }
//
//    func set(number: Int?) {
//        label.isHidden = (number == nil)
//        if let number = number {
//            circle.backgroundColor = selectionColor
//            circle.layer.borderColor = UIColor.clear.cgColor
//            circle.layer.borderWidth = 0
//            label.text = "\(number)"
//        } else {
//            circle.backgroundColor = UIColor.white.withAlphaComponent(0.3)
//            circle.layer.borderColor = UIColor.white.cgColor
//            circle.layer.borderWidth = 1
//            label.text = ""
//        }
//    }
//}
//
//class YPLibraryViewCell: UICollectionViewCell {
//
//    var representedAssetIdentifier  : String!
//    let imageView                   = UIImageView()
//    let durationLabel               = UILabel()
//    let selectionOverlay            = UIView()
//    let multipleSelectionIndicator  = YPMultipleSelectionIndicator()
//    let selectedImageView           = UIImageView()
//    var indexPath                   : IndexPath?
//
//    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        sv(
//            imageView,
//            durationLabel,
//            selectionOverlay,
//            multipleSelectionIndicator
//        )
//
//        imageView.fillContainer()
//        selectionOverlay.fillContainer()
//        layout(
//            durationLabel-5-|,
//            5
//        )
//
//        layout(
//            3,
//            multipleSelectionIndicator-3-|
//        )
//
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        durationLabel.textColor = .white
//        durationLabel.font = .systemFont(ofSize: 12)
//        durationLabel.isHidden = true
//        selectionOverlay.backgroundColor = .white
//        selectionOverlay.alpha = 0
//        backgroundColor = UIColor(r: 247, g: 247, b: 247)
//
//        //sigle select
////        sv(
////            imageView,
////            durationLabel,
////            selectionOverlay,
////            multipleSelectionIndicator
////        )
////
////        imageView.fillContainer()
////        selectionOverlay.fillContainer()
////        layout(
////            durationLabel-5-|,
////            5
////        )
////
////        layout(
////            3,
////            multipleSelectionIndicator-3-|
////        )
////
////        imageView.contentMode = .scaleAspectFill
////        imageView.clipsToBounds = true
////        durationLabel.textColor = .white
////        durationLabel.font = .systemFont(ofSize: 12)
////        durationLabel.isHidden = true
////        selectionOverlay.backgroundColor = .white
////        selectionOverlay.alpha = 0
////
////
////        selectedImageView.frame = CGRect(x: self.bounds.width - 25, y: 1.3, width: 24, height: 24) //multipleSelectionIndicator.frame
////        self.addSubview(selectedImageView)
////
////        backgroundColor = UIColor(r: 247, g: 247, b: 247)
//    }
//
//    override var isSelected: Bool {
//        didSet { isHighlighted = isSelected }
//    }
//
//    override var isHighlighted: Bool {
////        didSet {
////            selectionOverlay.alpha = isHighlighted ? 0.6 : 0
////
////        }
//
//
//        didSet {
//            if indexPath?.row != 0 {
//                if isSelected {
//                    selectionOverlay.alpha = isHighlighted ? 0.6 : 0
//                    multipleSelectionIndicator.set(number: indexPath?.row)
//                }
//            }
//
//
////            //unselect on camera
////            if indexPath?.row == 0 {
////                selectedImageView.removeFromSuperview()
////            }else{
////                self.addSubview(selectedImageView)
////                selectionOverlay.alpha = isHighlighted ? 0.6 : 0
////                multipleSelectionIndicator.set(number: indexPath?.row)
//////                selectedImageView.isHidden = !isHighlighted
//////                selectedImageView.image = isHighlighted ? UIImage(named: "txt_ico_verify") : nil
////            }
//
//        }
//    }
//}


//
//  YPLibraryViewCell.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia

class YPMultipleSelectionIndicator: UIView {
    
    let circle = UIView()
    let label = UILabel()
    var selectionColor = UIColor.black

    convenience init() {
        self.init(frame: .zero)
        
        let size: CGFloat = 20
        
        sv(
            circle,
            label
        )
        
        circle.fillContainer()
        circle.size(size)
        label.fillContainer()
        
        circle.layer.cornerRadius = size / 2.0
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        set(number: nil)
    }
    
    func set(number: Int?) {
        label.isHidden = (number == nil)
        if let number = number {
            circle.backgroundColor = selectionColor
            circle.layer.borderColor = UIColor.white.cgColor
            circle.layer.borderWidth = 2
            label.text = "\(number)"
        } else {
            circle.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            circle.layer.borderColor = UIColor.white.cgColor
            circle.layer.borderWidth = 2
            label.text = ""
        }
    }
}

class YPLibraryViewCell: UICollectionViewCell {
    
    var representedAssetIdentifier  : String!
    let imageView                   = UIImageView()
    let durationLabel               = UILabel()
    let selectionOverlay            = UIView()
    let multipleSelectionIndicator  = YPMultipleSelectionIndicator()
//    var selection                   = [YPLibrarySelection]()
//    var index                       = [IndexPath]()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sv(
            imageView,
            durationLabel,
            selectionOverlay,
            multipleSelectionIndicator
        )

        imageView.fillContainer()
        selectionOverlay.fillContainer()
        layout(
            durationLabel-5-|,
            5
        )
        
        layout(
            3,
            multipleSelectionIndicator-3-|
        )
        
        imageView.contentMode               = .scaleAspectFill
        imageView.clipsToBounds             = true
        durationLabel.textColor             = .white
        durationLabel.font                  = UIFont.systemFont(ofSize: 12, weight: .regular)
        durationLabel.isHidden              = true
        selectionOverlay.backgroundColor    = .white
        selectionOverlay.alpha              = 0
//        backgroundColor                     = UIColor(hexString: "#7010DF")
        backgroundColor                     = UIColor(r: 247, g: 247, b: 247)
    }

    override var isSelected: Bool {
        
        didSet { refreshSelection() }
    }
    
    override var isHighlighted: Bool {
        didSet { refreshSelection() }
    }
    
    private func refreshSelection() {
//        let showOverlay = isSelected || isHighlighted
//        selectionOverlay.alpha = showOverlay ? 0.6 : 0
    }
}
