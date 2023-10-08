//
//  CameraVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Linghor iMac on 4/6/21.
//

import UIKit
import AVFoundation

protocol SelectedImageDelegate : AnyObject {
    func didFinishSelectionImage(imageData: UIImage) -> Void
}

class CameraVC: UIViewController,AVCapturePhotoCaptureDelegate  {
    
    @IBOutlet weak var cameraView      : UIView!
    @IBOutlet weak var TapCaptureImage : UIImageView!
    
    @IBOutlet weak var switchButton    : UIButton!
    @IBOutlet weak var flashButton     : UIButton!
    @IBOutlet weak var dimissButton    : UIButton!
    
    var captureSession = AVCaptureSession()
    var cameraOutput   = AVCapturePhotoOutput()
    
    var backCamera  : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    
    var backInput   : AVCaptureInput!
    var frontInput  : AVCaptureInput!
    var input       : AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var backCameraOn = true
    var on: Bool     = false
    
    weak var delegate: SelectedImageDelegate?
    
//    weak var MainTabBarVC : MainTabBarVC?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    deinit {
        print("deinit")
        self.delegate = nil
        
    }
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TapCaptureImage.isExclusiveTouch = true
        self.cameraView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(tapOnCameraView(_:)))
        )
        self.setupAndStartCaptureSession()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGestureImageView(tapGestureRecognizer:)))
        
        TapCaptureImage.isUserInteractionEnabled = true
        TapCaptureImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillDisappear(animated)
    }
    
    //MARK: - set up camera Layer
    func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //set CameraView fullscreen
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = cameraView.layer.bounds
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
        self.view.bringSubviewToFront(cameraView)
        
    }
    
    //MARK:- Camera Setup
    func setupAndStartCaptureSession()  {
        //init session
        self.captureSession = AVCaptureSession()
        //start configuration
        self.captureSession.beginConfiguration()
        
        //session specific configuration
        if self.captureSession.canSetSessionPreset(.photo) {
            self.captureSession.sessionPreset = .photo
        }
        self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        
        //setup inputs
        self.setupInputs()
        
        if captureSession.canAddOutput(cameraOutput) {
            captureSession.addOutput(cameraOutput)
            //The reason for the crash is that the session.addOutput(output) was written incorrectly. session.canAddOutput(output)
            cameraOutput.isHighResolutionCaptureEnabled = true
        }else {
            captureSession.commitConfiguration()
            return
        }
        //setup preview layer
        self.setupPreviewLayer()
        
        //commit configuration
        self.captureSession.commitConfiguration()
        //start running it
        self.captureSession.startRunning()
    }
    
    // func input
    func setupInputs(){
        //get back camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            //handle this appropriately for production purposes
            fatalError("no back camera")
        }
        
        //get front camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else {
            fatalError("no front camera")
        }
        
        //now we need to create an input objects from our devices
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("could not create input device from back camera")
        }
        backInput = bInput
        if !captureSession.canAddInput(backInput) {
            fatalError("could not add back camera input to capture session")
        }
        
        guard let fInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("could not create input device from front camera")
        }
        frontInput = fInput
        if !captureSession.canAddInput(frontInput) {
            fatalError("could not add front camera input to capture session")
        }
        
        //connect back camera input to session
        captureSession.addInput(backInput)
    }
    
    //close camera
    @IBAction func dismissAction(_ sender: Any) {
        captureSession.stopRunning()
        popOrDismissVC()
        
    }
    
    @objc func tapOnCameraView(_ gesture: UITapGestureRecognizer) {
        
        let touchPoint = gesture.location(in: self.cameraView)
        let screenSize = cameraView.bounds.size
        let focusPoint = CGPoint(x: touchPoint.y / screenSize.height, y: 1.0 - touchPoint.x / screenSize.width)
        
        if let device = input?.device {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureDevice.FocusMode.autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
                }
                device.unlockForConfiguration()
                
            } catch {
                // Handle errors here
            }
        }
    }
    
    //objc func shot camera
    @objc func didTapGestureImageView(tapGestureRecognizer: UITapGestureRecognizer) {
        print("shot...")
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: TapCaptureImage.frame.width,
            kCVPixelBufferHeightKey as String: TapCaptureImage.frame.height
        ] as [String : Any]
        settings.previewPhotoFormat = previewFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    //func output
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            
            let sourceImage     = image
            var normalizeImage  : UIImage?
            
            if (sourceImage.imageOrientation == UIImage.Orientation.up) {
                normalizeImage = sourceImage
            }
            else {
                UIGraphicsBeginImageContextWithOptions(sourceImage.size, false, (sourceImage.scale))
                sourceImage.draw(in: CGRect(x: 0, y: 0, width: (sourceImage.size.width), height: (sourceImage.size.height)))
                
                let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                normalizeImage = normalizedImage
            }
            
//            print(normalizeImage, "NormalizeImage")
            self.captureSession.stopRunning()
            
            self.dismiss(animated: true) {
//                if let vc = self.navigationController?.viewControllers.filter({$0 is MainTabBarVC}).first as? MainTabBarVC {
//                    self.navigationController?.popToViewController(vc, animated: true)
//                    vc.uploadImageAfterCaptureSucess(normalizeImage: normalizeImage)
//                } else {
                    
                    if let vc = self.navigationController?.viewControllers.filter({$0 is YPPickerVC}).first as? YPPickerVC {
                        
                        self.navigationController?.popToViewController(vc, animated: true)
                        // vc.uploadImageAfterCaptureSucess(normalizeImage: normalizeImage)
                        
                        if let normalizeImage = normalizeImage {
                        }
                        
                    } else {
                        // Open Camera from MainTabBarVC, send capturing image to MainTabBar
                        if let normalizeImage = normalizeImage {
//                            MyNotify.send(name: .SuccessTakePhoto, object: normalizeImage)
                            self.delegate?.didFinishSelectionImage(imageData: normalizeImage)
                        }
                    }
//                }
            }
            
        }else {
            print("some error here")
        }
        
    }
    
    // func turn on/off flash
    @IBAction func flashAction(_ sender: UIButton) {
        
        let avDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        // check if the device has torch
        if ((avDevice?.hasTorch) != nil) {
            // lock your device for configuration
            do {
                let abv = try avDevice?.lockForConfiguration()
            } catch {
            }
            // check if your torchMode is on or off. If on turns it off otherwise turns it on
            if on == true {
                avDevice?.torchMode = AVCaptureDevice.TorchMode.off
                on = false
                self.flashButton.setImage(#imageLiteral(resourceName: "flash_off_ico"), for: .normal)
                print("flash off")
            } else {
                // sets the torch intensity to 100%
                do {
                    let abv = try avDevice?.setTorchModeOn(level: 1.0)
                    on = true
                    self.flashButton.setImage(#imageLiteral(resourceName: "flash_on_ico"), for: .normal)
                    print("flash on")
                } catch {
                }
                // avDevice.setTorchModeOnWithLevel(1.0, error: nil)
            }
            // unlock your device
            avDevice?.unlockForConfiguration()
        }
    }
    
    // func switch camera button
    @IBAction func switchAction(_ sender: Any) {
        print("switch camera")
        switchButton.isUserInteractionEnabled = false
        //reconfigure the input
        captureSession.beginConfiguration()
        if backCameraOn {
                self.captureSession.removeInput(self.backInput)
                self.captureSession.addInput(self.frontInput)
                self.flashButton.isEnabled = false
                self.backCameraOn = false
            } else {
                self.captureSession.removeInput(self.frontInput)
                self.captureSession.addInput(self.backInput)
                self.flashButton.isEnabled = true
                self.backCameraOn = true
            }
        //commit config
        captureSession.commitConfiguration()
        
        //acitvate the camera button again
        switchButton.isUserInteractionEnabled = true
    }
}


