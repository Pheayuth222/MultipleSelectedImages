//
//  WCImagePicker.swift
//  semo
//
//  Created by vansa pha on 09/07/2019.
//  Copyright © 2019 Webcash. All rights reserved.
//

//import YPImagePicker
import UIKit

class InstaImagePicker {
    
//     func showInstaPopupImage(owner : UIViewController,completeBlock : ((UIImage) -> Void)?)  {
//        
//        var config = YPImagePickerConfiguration()
//        config.shouldSaveNewPicturesToAlbum     = false
//        config.library.mediaType                = .photo
//        config.startOnScreen                    = .library
//        config.showsPhotoFilters                = false
//        config.targetImageSize                  = .original
//        config.hidesStatusBar                   = false
//       
//        
//        config.wordings.libraryTitle            = "gallery"
//        config.wordings.next                    = "select"
//        config.wordings.cancel                  = "cancel_btn"
//        config.wordings.cameraTitle             = "camera"
//        config.wordings.done                    = "select"
//        config.wordings.warningMaxItemsLimit    = "사진과 동영상은 최대 10개 까지 선택할 수 있습니다."
//        
//        
////        let defaultFont     = UIFont(name: "Inter-Bold", size: 15)
////        let fontNameToTest  = defaultFont!.fontName.lowercased();
////        let fontName        = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
////        let font            =  UIFont(name: fontName, size: defaultFont!.pointSize)
////
////        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9"), NSAttributedString.Key.font: font! ] // Title color
////        UINavigationBar.appearance().tintColor = UIColor(hexString: "0069B9") // Left. bar buttons
////        //config.colors.tintColor = .pinky // Right bar buttons (actions)
////
////
////        let attrsBarButton = [
////            NSAttributedString.Key.font: UIFont(name: fontName, size: 15)!,
////            NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9")
////        ]
////        UIBarButtonItem.appearance().setTitleTextAttributes(attrsBarButton, for: .normal)
//
//        let picker = YPImagePicker(configuration: config)
//        //picker.navigationBar.barTintColor = .pinky
//        picker.didFinishPicking { [unowned picker] items, _ in
//            if let photo = items.singlePhoto {
//                completeBlock!(photo.image)
//            }
//            picker.dismiss(animated: true, completion: nil)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            owner.present(picker, animated: true, completion: nil)
//        }
//    }
    
//    func showInstaPopupMultipleImage(owner : UIViewController, isCreate: YPPickerScreen, maxImages: Int,completeBlock : (([UIImage]) -> Void)?)  {
//        
//        var config = YPImagePickerConfiguration()
//        config.shouldSaveNewPicturesToAlbum             = false
//        config.library.mediaType                        = .photo
//        config.startOnScreen                            = isCreate
//        config.showsPhotoFilters                        = false
//        config.library.skipSelectionsGallery            = true
//        config.targetImageSize                          = .original
//        config.hidesStatusBar                           = false
//        config.library.maxNumberOfItems                 = maxImages
//        config.library.defaultMultipleSelection         = false
//        config.preferredStatusBarStyle                  = .default
//        
//        config.wordings.libraryTitle                    = "Add Photos"//"gallery"
//        config.wordings.next                            = "select"
//        config.wordings.cancel                          = ""//"cancel_btn".localized // "back".localized
//        config.wordings.cameraTitle                     = "camera"
//        config.wordings.done                            = "Next" //"select" // "choose".localized
//        config.wordings.warningMaxItemsLimit            = ""
//        config.colors.coverSelectorBorderColor          = .red
////        config.colors.multipleItemsSelectedCircleColor  = UIColor(hexString: "0069B9")
////        config.colors.tintColor                         = UIColor(hexString: "0069B9") // Right bar buttons (actions)
//        
////        let defaultFont     = UIFont(name: "Inter-Bold", size: 15)
////        let fontNameToTest  = defaultFont!.fontName.lowercased()
////        let fontName        = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
////        let font            = UIFont(name: fontName, size: defaultFont!.pointSize)
//
//        // #494949
////        UINavigationBar.appearance().titleTextAttributes    = [NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9"),  NSAttributedString.Key.font : font!] // Title color nav bar
////        UINavigationBar.appearance().tintColor              = UIColor(hexString: "0069B9") // Left. bar buttons
//
////        let attrsBarButton = [
////            NSAttributedString.Key.font: UIFont(name: fontName, size: 15)!,
////            NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9")
////        ]
////        UIBarButtonItem.appearance().setTitleTextAttributes(attrsBarButton, for: .normal)
//////        UINavigationBar.appearance().barTintColor = .pinky
////        UINavigationBar.appearance().isTranslucent = false
//    
//        let picker = YPImagePicker(configuration: config)
//        /*
//         Presentation style changed in iOS 13
//         */
//        picker.modalPresentationStyle = .fullScreen
//        picker.navigationBar.barTintColor = .white
//        picker.didFinishPicking { [unowned picker] items, _ in
//            var imgArr : [UIImage] = []
//            for item in items {
//                switch item {
//                case .photo(let photo):
//                    imgArr.append(photo.image)// = photo.image
//                default:
//                    break
//                }
//            }
//            picker.dismiss(animated: true, completion: {
//                
//                completeBlock!(imgArr)
//            })
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            owner.present(picker, animated: true, completion: nil)
//        }
//        
//    }
    
}
