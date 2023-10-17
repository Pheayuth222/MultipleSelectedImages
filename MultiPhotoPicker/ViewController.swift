//
//  ViewController.swift
//  MultiPhotoPicker
//
//  Created by KOSIGN on 5/10/23.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    private var imagesArr: [UIImage] = []
    private let maxImages       : Int = 500
    private var documentManager     : DocumentsManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "サンプル文字列"
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
                let vc = self.PopupVC(storyboard: "CameraSB", identifier: "CameraVC") as! CameraVC
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
                
            }
        }
    }
    
    func openGallery() {
//        Shared.isFromMainTabBar     = true
        let CURRENT_MAX_IMAGES   = 5
        // Multiple Selection
        showInstaPopupMultipleImage(owner: self, isCreate: .library, maxImages: maxImages) { (imgs) in
            if imgs.count > 0 {
                self.didFinishPickImages(images: imgs)
                print("Images...: \(imgs)")
            }
        }
        
        // Single Select
//        InstaImagePicker.showInstaPopupImage(owner: self) { (imgs) in
//            self.didFinishSelectionImage(imageData: imgs)
//            print(imgs)
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    // TODO: - Upload Image from gallery
    func didFinishPickImages(images: [UIImage]) {
        
        if images.count != 0 {
            
            for (i, image) in images.enumerated() {
                if let base64 = convertToBase64(image) {
                    let formatter           = DateFormatter()
                    formatter.dateFormat    = "yyyMMddHHmm"
                    // REC_IN.append(WABOOKS_MREC_C002.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date())).jpg", FILE_DATA: base64))
                    
//                    REC_IN.append(WABOOKS_MREC_C002.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date()))\(i).jpg", FILE_DATA: base64))
                }
            }
            self.imagesArr = images
            tableView.reloadData()
            // Upload image
//            self.uploadImage(body: WABOOKS_MREC_C002.REQUEST(REC_IN: REC_IN)) {
//                DispatchQueue.main.async {
//                    self.dismiss(animated: true) {
//                        MyNotify.send(name:.reloadAfterUploadImage)
//                    }
//                }
//            }
        }
        
    }
    
    func openAttachFile() {
        
        self.documentManager = DocumentsManager(self)
        self.documentManager.openDocument()
        self.documentManager.isNotFromSubmit = true
        self.documentManager.completionError = { error in
//            self.alert(message: error.localizedDescription)
            print(error.localizedDescription)
        }
//        self.documentManager.completionFileInfo = { files in
//            print(files)
//        }

    }
    

    @IBAction func addPhoto(_ sender: UIButton) {
//        let storyBoard = UIStoryboard(name: "ChoosePhotoSB", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "ChoosePhotoVC") as! ChoosePhotoVC
//        let nav = UINavigationController.init(rootViewController: vc)
//        self.presetVC(vc: nav)
//        sender.animateButtonUp()
        openGallery()
//        customOption(type       : .MultipleChoice,
//                     image      : "",
//                     title      : "Take Picture",
//                     message    : "Take a photo or choose from a gallery",
//                     data       : ["Take a Photo", "Take a photo or choose from a gallery", "Attach File"],
//                     selectRowAt: -1,
//                     imgStrRec  : ["camera_ico", "gallery_ico", "tap_attachment"]) { [unowned self](index) in
//            switch index {
//            case 0:
//                self.view.endEditing(true)
//                self.checkCameraPermisson()
//
//            case 1  : self.openGallery()
//            case 2  : self.openAttachFile()
//            default : break
//            }
//        }
    }
    
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 :
            return 1
        default : return imagesArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section  {
        case 0 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            return cell
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: "GetImageTableCell", for: indexPath) as! GetImageTableCell
            cell.getImageView.image = imagesArr[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section  {
        case 0 :
            return 56
        default :
            return 110
        }
    }
    
}


extension UIViewController {
    func presetVC(vc: UIViewController, modalPresentStyle: UIModalPresentationStyle = .fullScreen) {
        vc.modalPresentationStyle = modalPresentStyle
        self.present(vc, animated: true, completion: nil)
    }
}


class GetImageTableCell: UITableViewCell {
    @IBOutlet weak var getImageView: UIImageView!
}

extension ViewController : SelectedImageDelegate {
    func didFinishSelectionImage(imageData: UIImage) {
        print("Image Data : \(imageData)")
        imagesArr.append(imageData)
        tableView.reloadData()
    }
    
}


extension ViewController {
    
    func showInstaPopupMultipleImage(owner : UIViewController, isCreate: YPPickerScreen, maxImages: Int,completeBlock : (([UIImage]) -> Void)?)  {
        
        var config = YPImagePickerConfiguration()
        config.shouldSaveNewPicturesToAlbum             = false
        config.library.mediaType                        = .photo
        config.startOnScreen                            = isCreate
        config.showsPhotoFilters                        = false
        config.library.skipSelectionsGallery            = true
        config.targetImageSize                          = .original
        config.hidesStatusBar                           = false
        config.library.maxNumberOfItems                 = maxImages
        config.library.defaultMultipleSelection         = false
        config.preferredStatusBarStyle                  = .default
        
        config.wordings.libraryTitle                    = "Add Photos"//"gallery"
        config.wordings.next                            = "select"
        config.wordings.cancel                          = ""//"cancel_btn".localized // "back".localized
        config.wordings.cameraTitle                     = "camera"
        config.wordings.done                            = "Next" //"select" // "choose".localized
        config.wordings.warningMaxItemsLimit            = ""
        config.colors.coverSelectorBorderColor          = .red
//        config.colors.multipleItemsSelectedCircleColor  = UIColor(hexString: "0069B9")
//        config.colors.tintColor                         = UIColor(hexString: "0069B9") // Right bar buttons (actions)
        
//        let defaultFont     = UIFont(name: "Inter-Bold", size: 15)
//        let fontNameToTest  = defaultFont!.fontName.lowercased()
//        let fontName        = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
//        let font            = UIFont(name: fontName, size: defaultFont!.pointSize)

        // #494949
//        UINavigationBar.appearance().titleTextAttributes    = [NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9"),  NSAttributedString.Key.font : font!] // Title color nav bar
//        UINavigationBar.appearance().tintColor              = UIColor(hexString: "0069B9") // Left. bar buttons

//        let attrsBarButton = [
//            NSAttributedString.Key.font: UIFont(name: fontName, size: 15)!,
//            NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9")
//        ]
//        UIBarButtonItem.appearance().setTitleTextAttributes(attrsBarButton, for: .normal)
////        UINavigationBar.appearance().barTintColor = .pinky
//        UINavigationBar.appearance().isTranslucent = false
    
        let picker = YPImagePicker(configuration: config)
        /*
         Presentation style changed in iOS 13
         */
        picker.modalPresentationStyle = .fullScreen
        picker.navigationBar.barTintColor = .white
        picker.didFinishPicking { [unowned picker] items, _ in
            var imgArr : [UIImage] = []
            for item in items {
                switch item {
                case .photo(let photo):
                    imgArr.append(photo.image)// = photo.image
                default:
                    break
                }
            }
            picker.dismiss(animated: true, completion: {
                
                completeBlock!(imgArr)
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            owner.present(picker, animated: true, completion: nil)
        }
        
    }
    
    func showInstaPopupImage(owner : UIViewController,completeBlock : ((UIImage) -> Void)?)  {
       
       var config = YPImagePickerConfiguration()
       config.shouldSaveNewPicturesToAlbum     = false
       config.library.mediaType                = .photo
       config.startOnScreen                    = .library
       config.showsPhotoFilters                = false
       config.targetImageSize                  = .original
       config.hidesStatusBar                   = false
      
       
       config.wordings.libraryTitle            = "gallery"
       config.wordings.next                    = "select"
       config.wordings.cancel                  = "cancel_btn"
       config.wordings.cameraTitle             = "camera"
       config.wordings.done                    = "select"
       config.wordings.warningMaxItemsLimit    = "사진과 동영상은 최대 10개 까지 선택할 수 있습니다."
       
       
//        let defaultFont     = UIFont(name: "Inter-Bold", size: 15)
//        let fontNameToTest  = defaultFont!.fontName.lowercased();
//        let fontName        = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
//        let font            =  UIFont(name: fontName, size: defaultFont!.pointSize)
//
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9"), NSAttributedString.Key.font: font! ] // Title color
//        UINavigationBar.appearance().tintColor = UIColor(hexString: "0069B9") // Left. bar buttons
//        //config.colors.tintColor = .pinky // Right bar buttons (actions)
//
//
//        let attrsBarButton = [
//            NSAttributedString.Key.font: UIFont(name: fontName, size: 15)!,
//            NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9")
//        ]
//        UIBarButtonItem.appearance().setTitleTextAttributes(attrsBarButton, for: .normal)

       let picker = YPImagePicker(configuration: config)
       //picker.navigationBar.barTintColor = .pinky
       picker.didFinishPicking { [unowned picker] items, _ in
           if let photo = items.singlePhoto {
               completeBlock!(photo.image)
           }
           picker.dismiss(animated: true, completion: nil)
       }
       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
           owner.present(picker, animated: true, completion: nil)
       }
   }
    
}
