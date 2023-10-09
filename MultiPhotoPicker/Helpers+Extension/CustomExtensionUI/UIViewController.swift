//
//  UIViewController.swift
//  MultiPhotoPicker
//
//  Created by YuthFight's MacBook Pro  on 8/10/23.
//

import UIKit
import AVFoundation

extension UIViewController {
    
    func VC(sbName: String, identifier: String) -> UIViewController {
        return UIStoryboard(name: sbName, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    func pushVC(viewController: UIViewController, animated: Bool = true) {
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
    func popOrDismissVC(animated: Bool = true, completion: @escaping Completion = { }) {
        if let nav = self.navigationController {
            nav.popViewController(animated: animated)
            completion()
        }
        else {
            self.dismiss(animated: animated) {
                completion()
            }
        }
    }
    
    func PopupVC(storyboard: String, identifier: String) -> UIViewController {
        let vc = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        
        return vc
    }
    
    func callCommonPopup(withStorybordName storyboard: String, identifier: String) -> UIViewController {
        let vc = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle                       = .overFullScreen
        vc.modalTransitionStyle                         = .crossDissolve
        vc.providesPresentationContextTransitionStyle   = true
        vc.definesPresentationContext                   = true
        return vc
    }
    
    func alertYesNo(title: String, message: String, nobtn: String = "NO".capitalized, yesbtn: String = "YES".capitalized
                    , completion: @escaping Completion_Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: yesbtn, style: .default, handler: { (action) -> Void in
                completion(true)
            })
        )
        alert.addAction(
            UIAlertAction(title: nobtn, style: .cancel)
        )
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkAllowCameraPermission(completion: @escaping Completion_Bool) {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
                DispatchQueue.main.async {
                    completion(granted)
                }
            })
        }
        else {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    func gotoAppSettings() {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
        }
    }
    
}
