//
//  ChoosePhotoVC.swift
//  MultiPhotoPicker
//
//  Created by KOSIGN on 5/10/23.
//

import UIKit
import CarbonKit

class ChoosePhotoVC: UIViewController,CarbonTabSwipeNavigationDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var controllerNames = ["All","Photos","Album"]
    var carbonTapSwipeNavigation = CarbonTabSwipeNavigation()
    
//    var imagePicker = UIImagePickerController()
    var picker = UIImagePickerController();
        var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        var viewController: UIViewController?
        var pickImageCallback : ((UIImage) -> ())?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        carbonTapSwipeNavigation = CarbonTabSwipeNavigation(items: controllerNames, delegate: self)
        carbonTapSwipeNavigation.insert(intoRootViewController: self)
        carbonTapSwipeNavigation.setTabBarHeight(50)
        carbonTapSwipeNavigation.setTabExtraWidth(50)
        carbonTapSwipeNavigation.carbonTabSwipeScrollView.backgroundColor = UIColor.white
        carbonTapSwipeNavigation.setIndicatorHeight(2)
        carbonTapSwipeNavigation.setSelectedColor(UIColor.purple)
        carbonTapSwipeNavigation.carbonSegmentedControl?.backgroundColor = UIColor.white
        
        carbonTapSwipeNavigation.setIndicatorColor(UIColor.purple)
        carbonTapSwipeNavigation.setNormalColor(UIColor.gray)
        
        //position
        carbonTapSwipeNavigation.carbonSegmentedControl?.indicatorPosition = .bottom
    }
    
    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnClicked() {
        openGallery()
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        guard let storyboard = storyboard else { return
            UIViewController()
        }
        
        if index == 0 {
            return storyboard.instantiateViewController(withIdentifier: "AllPhotoVC")
        }else if index == 1 {
            return storyboard.instantiateViewController(withIdentifier: "PhotoVC")
        }else{
            return storyboard.instantiateViewController(withIdentifier: "AlbumVC")
        }
    }
    

}


extension ChoosePhotoVC {
    
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
        self.viewController = viewController;
        
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            viewController?.present(alertController, animated: true)
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.viewController?.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    //for swift below 4.2
    //func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //    picker.dismiss(animated: true, completion: nil)
    //    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    //    pickImageCallback?(image)
    //}
    
    // For Swift 4.2+
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        pickImageCallback?(image)
    }
    
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
    }
}
