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
    private let maxImages       : Int = 100
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
        InstaImagePicker.showInstaPopupMultipleImage(owner: self, isCreate: .library, maxImages: maxImages) { (imgs) in
            if imgs.count > 0 {
                self.didFinishPickImages(images: imgs)
                print("Images...: \(imgs)")
            }
        }
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
        customOption(type       : .MultipleChoice,
                     image      : "",
                     title      : "Take Picture",
                     message    : "Take a photo or choose from a gallery",
                     data       : ["Take a Photo", "Take a photo or choose from a gallery", "Attach File"],
                     selectRowAt: -1,
                     imgStrRec  : ["camera_ico", "gallery_ico", "tap_attachment"]) { [unowned self](index) in
            switch index {
            case 0:
                self.view.endEditing(true)
                self.checkCameraPermisson()
                
            case 1  : self.openGallery()
            case 2  : self.openAttachFile()
            default : break
            }
        }
    }
    
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GetImageTableCell", for: indexPath) as! GetImageTableCell
        cell.getImageView.image = imagesArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
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
