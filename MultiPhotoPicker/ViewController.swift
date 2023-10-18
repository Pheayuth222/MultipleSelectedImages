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
            }
        }
    }
    
    // TODO: - Upload Image from gallery
    func didFinishPickImages(images: [UIImage]) {
        
        if images.count != 0 {
            
            for (index, image) in images.enumerated() {
                if let base64 = convertToBase64(image) {
                    let formatter           = DateFormatter()
                    formatter.dateFormat    = "yyyMMddHHmm"
                }
            }
            self.imagesArr = images
            tableView.reloadData()
        }
        
    }
    
    func openAttachFile() {
        
        self.documentManager = DocumentsManager(self)
        self.documentManager.openDocument()
        self.documentManager.isNotFromSubmit = true
        self.documentManager.completionError = { error in
            print(error.localizedDescription)
        }
    }
    

    @IBAction func addPhoto(_ sender: UIButton) {
        openGallery()
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
