//
//  YYPPickerVC.swift
//  YPPickerVC
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import Stevia
import Photos
import CarbonKit

protocol ImagePickerDelegate: AnyObject {
    func noPhotos()
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool

}

open class YPPickerVC: YPBottomPager, YPBottomPagerDelegate,CarbonTabSwipeNavigationDelegate {
    
    let albumsManager = YPAlbumsManager()
    var shouldHideStatusBar = false
    var initialStatusBarHidden = false
    var CURRENT_MAX_IMAGES   : Int = 5
    
//    var maintabVM               = MainTabBarVM()
//    private var responseImage   : WABOOKS_MREC_C002.RESPONSE?
    
    weak var imagePickerDelegate: ImagePickerDelegate?
    
    override open var prefersStatusBarHidden: Bool {
        return (shouldHideStatusBar || initialStatusBarHidden) && YPConfig.hidesStatusBar
    }
    
    /// Private callbacks to YPImagePicker
    public var didClose:(() -> Void)?
    public var didSelectItems: (([YPMediaItem]) -> Void)?
    
    enum Mode {
        case library
        case camera
        case video
    }
    
    private var libraryVC: YPLibraryVC?
    private var cameraVC: YPCameraVC?
    private var videoVC: YPVideoCaptureVC?
    
    var mode = Mode.camera
    
    var capturedImage: UIImage?
    
    var controllerNames = ["All","Photos","Album"]
    var carbonTapSwipeNavigation = CarbonTabSwipeNavigation()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(r: 247, g: 247, b: 247)
        
        delegate = self
        
        // Force Library only when using `minNumberOfItems`.
        if YPConfig.library.minNumberOfItems > 1 {
            YPImagePickerConfiguration.shared.screens = [.library]
        }
        
        // Library
        if YPConfig.screens.contains(.library) {
            libraryVC = YPLibraryVC()
            libraryVC?.delegate = self
        }
        
        // Camera
        if YPConfig.screens.contains(.photo) {
            cameraVC = YPCameraVC()
            cameraVC?.didCapturePhoto = { [weak self] img in
                self?.didSelectItems?([YPMediaItem.photo(p: YPMediaPhoto(image: img,
                                                                        fromCamera: true))])
            }
        }
        
        // Video
        if YPConfig.screens.contains(.video) {
            videoVC = YPVideoCaptureVC()
            videoVC?.didCaptureVideo = { [weak self] videoURL in
                self?.didSelectItems?([YPMediaItem
                    .video(v: YPMediaVideo(thumbnail: thumbnailFromVideoPath(videoURL),
                                           videoURL: videoURL,
                                           fromCamera: true))])
            }
        }
        
        // Show screens
        var vcs = [UIViewController]()
        for screen in YPConfig.screens {
            switch screen {
            case .library:
                if let libraryVC = libraryVC {
                    vcs.append(libraryVC)
                }
            case .photo:
                if let cameraVC = cameraVC {
                    vcs.append(cameraVC)
                }
            case .video:
                if let videoVC = videoVC {
                    vcs.append(videoVC)
                }
            }
        }
        controllers = vcs
        
        // Select good mode
        if YPConfig.screens.contains(YPConfig.startOnScreen) {
            switch YPConfig.startOnScreen {
            case .library:
                mode = .library
            case .photo:
                mode = .camera
            case .video:
                mode = .video
            }
        }
        
        // Select good screen
        if let index = YPConfig.screens.firstIndex(of: YPConfig.startOnScreen) {
            startOnPage(index)
        }
        
        YPHelper.changeBackButtonIcon(self)
        YPHelper.changeBackButtonTitle(self)
        
//        configCabonKitView()
    }
    
    private func configCabonKitView() {
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
    
    
    public func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        guard let storyboard = storyboard else { return
            UIViewController()
        }
        
        if index == 0 {
            return storyboard.instantiateViewController(withIdentifier: "YPLibraryVC")
        }else if index == 1 {
            return storyboard.instantiateViewController(withIdentifier: "PhotoVC")
        }else{
            return storyboard.instantiateViewController(withIdentifier: "AlbumVC")
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        setColorArtibuteNav: do {
//            let defaultFont     = UIFont(name: "Rubik", size: 14)
//            let fontNameToTest  = defaultFont!.fontName.lowercased()
//            let fontName        = Shared.share.getLocalizedFont(preFontName: fontNameToTest)
//            let attrsBarButton = [
//                NSAttributedString.Key.font: UIFont(name: fontName, size: 15)!,
//                NSAttributedString.Key.foregroundColor : UIColor(hexString: "0069B9")
//            ]
//            UIBarButtonItem.appearance().setTitleTextAttributes(attrsBarButton, for: .normal)
//        }
        
        cameraVC?.v.shotButton.isEnabled = true
        
        updateMode(with: currentController)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldHideStatusBar = true
        initialStatusBarHidden = true
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    internal func pagerScrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //disable scroll Horizontal Scroll Lock
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    func modeFor(vc: UIViewController) -> Mode {
        switch vc {
        case is YPLibraryVC:
            return .library
        case is YPCameraVC:
            return .camera
        case is YPVideoCaptureVC:
            return .video
        default:
            return .camera
        }
    }
    
    //upload image after capture
//    func uploadImageAfterCaptureSucess (normalizeImage : UIImage?) {
//
//        var REC_IN : [WABOOKS_MREC_C002.REQUEST.REC] = []
//
//        if let base64 = convertToBase64(normalizeImage ?? UIImage()) {
//            let formatter           = DateFormatter()
//            formatter.dateFormat    = "yyyMMddHHmm"
//            // REC_IN.append(WABOOKS_MREC_C002.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date())).jpg", FILE_DATA: base64))
//
//
//            // Upload Image after taking a photo
//            self.uploadImage(body: WABOOKS_MREC_C002.REQUEST(REC_IN: [])) {
//                // Reload Receipt List After Upload Image Success
//                MyNotify.send(name: .reloadAfterUploadImage)
//            }
//        }
//    }
    
    // Fetching API
//    private func uploadImage(body: WABOOKS_MREC_C002.REQUEST, _ completion: @escaping () -> () = {}) {
//        self.maintabVM.uploadImage(body: WABOOKS_MREC_C002.REQUEST(
//                                        REC_IN: [])) { (error) in
//            if error != nil {
//                self.customAlert(type       : .CONFIRM_ALERT,
//                                 image      : "popup_failed_badge",
//                                 title      : "notification".localized,
//                                 message    : error?.localizedDescription ?? "Error",
//                                 redTitle   : "",
//                                 greyTitle  : "ok".localized) { (_) in
//                }
//                return
//            }
//
//            self.responseImage = self.maintabVM.reponseImage
//            completion()
//        }
//    }
    
    func pagerDidSelectController(_ vc: UIViewController) {
        updateMode(with: vc)
    }
    
    func updateMode(with vc: UIViewController) {
        stopCurrentCamera()
        
        // Set new mode
        mode = modeFor(vc: vc)
        
        // Re-trigger permission check
        if let vc = vc as? YPLibraryVC {
            vc.checkPermission()
        } else if let cameraVC = vc as? YPCameraVC {
            cameraVC.start()
        } else if let videoVC = vc as? YPVideoCaptureVC {
            videoVC.start()
        }
    
        updateUI()
    }
    
    func stopCurrentCamera() {
        switch mode {
        case .library:
            libraryVC?.pausePlayer()
        case .camera:
            cameraVC?.stopCamera()
        case .video:
            videoVC?.stopCamera()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldHideStatusBar = false
        stopAll()
    }
    
    @objc func navBarTapped() {
        let vc = YPAlbumVC(albumsManager: albumsManager)
        let navVC = UINavigationController(rootViewController: vc)
        
        vc.didSelectAlbum = { [weak self] album in
            self?.libraryVC?.setAlbum(album)
            self?.setTitleViewWithTitle(aTitle: album.title)
            self?.dismiss(animated: true, completion: nil)
        }
        present(navVC, animated: true, completion: nil)
    }
    
    func setTitleViewWithTitle(aTitle: String) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        let label = UILabel()
        label.text = aTitle
        // Use standard font by default.
        label.font = UIFont.boldSystemFont(ofSize: 15)
        
        // Use custom font if set by user.
        if let navBarTitleFont = UINavigationBar.appearance().titleTextAttributes?[.font] as? UIFont {
            // Use custom font if set by user.
            label.font = navBarTitleFont
        }
        // Use custom textColor if set by user.
        if let navBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[.foregroundColor] as? UIColor {
            label.textColor = navBarTitleColor
        }
        
        if YPConfig.library.options != nil {
            titleView.sv(
                label
            )
            |-(>=8)-label.centerHorizontally()-(>=8)-|
            align(horizontally: label)
        } else {
            let arrow = UIImageView()
//            arrow.image = YPConfig.icons.arrowDownIcon
            arrow.image = UIImage(named: "arrow_drop_down_black_24dp")
            let attributes = UINavigationBar.appearance().titleTextAttributes
            if let attributes = attributes, let foregroundColor = attributes[NSAttributedString.Key.foregroundColor] as? UIColor {
                arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
                arrow.tintColor = foregroundColor
            }
            
            let button = UIButton()
//            button.addTarget(self, action: #selector(navBarTapped), for: .touchUpInside)
            button.setBackgroundColor(UIColor.white.withAlphaComponent(0.5), forState: .highlighted)
            
            titleView.sv(
                label,
                arrow,
                button
            )
            button.fillContainer()
            |-(>=8)-label.centerHorizontally()-arrow-(>=8)-|
            align(horizontally: label-arrow)
        }
        
        label.firstBaselineAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -14).isActive = true
        
        
        
        titleView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.titleView = titleView
    }
    
    func updateUI() {
        // Update Nav Bar state.
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.cancel,
//                                                           style: .plain,
//                                                           target: self,
//                                                           action: #selector(close))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
                                                           image: UIImage(named: "arrow_back_ios_black_24dp"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(close))
        switch mode {
        case .library:
            setTitleViewWithTitle(aTitle: libraryVC?.title ?? "")
            
            //Chay: 01-09-2021
            let imageSelect = libraryVC!.selectionArr.count > 0 ? " (\(libraryVC!.selectionArr.count))" : ""
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.done + imageSelect,
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(done))
            navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor
            
            // Disable Next Button until minNumberOfItems is reached.
            if libraryVC!.selectionArr.count >= YPConfig.library.minNumberOfItems {
                if libraryVC!.selectionArr.count > CURRENT_MAX_IMAGES {
                    navigationItem.rightBarButtonItem?.isEnabled = false
                }else{
                    navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }else{
                navigationItem.rightBarButtonItem?.isEnabled = false
            }

        case .camera:
            navigationItem.titleView = nil
            title = cameraVC?.title
            navigationItem.rightBarButtonItem = nil
        case .video:
            navigationItem.titleView = nil
            title = videoVC?.title
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc
    func close() {
        // Cancelling exporting of all videos
        if let libraryVC = libraryVC {
            libraryVC.mediaManager.forseCancelExporting()
        }
        self.didClose?()
    }
    
    // When pressing "Next"
    @objc
    func done() {
        guard let libraryVC = libraryVC else { print("⚠️ YPPickerVC >>> YPLibraryVC deallocated"); return }
        
        if mode == .library {
            libraryVC.doAfterPermissionCheck { [weak self] in
                libraryVC.selectedMedia(photoCallback: { photo in
                    self?.didSelectItems?([YPMediaItem.photo(p: photo)])
                }, videoCallback: { video in
                    self?.didSelectItems?([YPMediaItem
                        .video(v: video)])
                }, multipleItemsCallback: { items in
                    self?.didSelectItems?(items)
                })
            }
        }
    }
    
    func stopAll() {
        libraryVC?.v.assetZoomableView.videoView.deallocate()
        videoVC?.stopCamera()
        cameraVC?.stopCamera()
    }
}

extension YPPickerVC: YPLibraryViewDelegate {
    public func libraryViewShouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return imagePickerDelegate?.shouldAddToSelection(indexPath: indexPath, numSelections: numSelections) ?? true
    }
    
    
    public func libraryViewStartedLoading() {
        libraryVC?.isProcessing = true
        DispatchQueue.main.async {
            self.v.scrollView.isScrollEnabled = false
            self.libraryVC?.v.fadeInLoader()
            self.navigationItem.rightBarButtonItem = YPLoaders.defaultLoader
        }
    }
    
    public func libraryViewFinishedLoading() {
        libraryVC?.isProcessing = false
        DispatchQueue.main.async {
            self.v.scrollView.isScrollEnabled = YPConfig.isScrollToChangeModesEnabled
            self.libraryVC?.v.hideLoader()
            self.updateUI()
        }
    }
    
    public func libraryViewDidToggleMultipleSelection(enabled: Bool) {
        var offset = v.header.frame.height
        if #available(iOS 11.0, *) {
            offset += v.safeAreaInsets.bottom
        }
        
        v.header.bottomConstraint?.constant = enabled ? offset : 0
        v.layoutIfNeeded()
        updateUI()
    }
    
    public func noPhotosForOptions() {
        self.dismiss(animated: true) {
            self.imagePickerDelegate?.noPhotos()
        }
    }
}
