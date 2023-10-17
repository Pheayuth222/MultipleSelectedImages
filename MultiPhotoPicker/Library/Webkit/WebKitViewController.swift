//
//  WebKitViewController.swift
//  SimpleCert
//
//  Created by Dom on 10/30/19.
//  Copyright © 2019 Webcash. All rights reserved.
//

import UIKit

enum WebKitType {
    case General
    case ASP
    case HubLink
    case WA_NOTIFICATION
}

class WebKitViewController: UIViewController {

    // MARK: - Property
    
    var webKitType = WebKitType.General
    
    private var webKit          : BaseWebView! // Swift
    private var wkBaseWebView   : WkBaseWebView! // Objective-C -> Test 90% work the same with Swift
    
    private var urlStr          : String!
    private var isBounce        : Bool = true
    private var visualStatusBarViw: UIView!
    private var param           : String?
    private var addOnHeader     : Dictionary<String, String>?
    private var isMiniWebView   : Bool = false
    private var finishedUrl     : String?
    
    private var titleString = "" {
        didSet {
            self.title = self.titleString
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withURL url : String, isMini: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.urlStr         = url
        self.isMiniWebView  = isMini
    }
    
    init(withURL url : String, param: String, header: Dictionary<String, String>? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.urlStr      = url
        self.param       = param
        self.addOnHeader = header
    }
    
    init(withURL url : String, isScrollBounce: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.urlStr     = url
        self.view.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        self.isBounce   = isScrollBounce
    }
    
    // MARK: - Life Cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        switch webKitType {
        case .ASP:
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                // Fallback on earlier versions
                return .default
            }
        default:
           return .lightContent
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(false, animated: animated)
       
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    @objc 
    override func viewDidLoad() {
        super.viewDidLoad()
        //Change ViewController title Color
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        // refresh layout before append webview as subview
        self.view.layoutIfNeeded()
        self.setupBaseWebview()
        
        self.view.backgroundColor = isMiniWebView ? .clear : UIColor.white
        
        
        DispatchQueue.main.async {
            switch self.webKitType {
            case .ASP:
                let menuDic = ["_title" : "", "_type" : "10"]
                self.webNavigationBarStyle(ad: menuDic)
            case .HubLink:
                let menuDic = ["_title" : "", "_type" : "11"]
                self.webNavigationBarStyle(ad: menuDic)
                self.navigationController?.setNavigationBarHidden(true, animated: false)
            case .WA_NOTIFICATION ://Sreinin Detail Notification
                let leftButton = UIButton(frame: CGRect(x: 20, y: 0, width: 50, height: 33))
                leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
                leftButton.contentHorizontalAlignment = .left
                leftButton.setImage(UIImage(named: "head_close_white"), for: UIControl.State())
                leftButton.addTarget(self, action: #selector(self.navigationBarButtonActionHandler(sender:)), for: .touchUpInside)
                
                let leftBarButton = UIBarButtonItem(customView: leftButton)
                self.navigationItem.leftBarButtonItem = leftBarButton
                self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "216CB6")
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            default:
                let menuDic = ["_title" : "", "_type" : "2"]
                self.webNavigationBarStyle(ad: menuDic)
            }
        }
        
        
        DataAccess.shared.startSessionTimeout(isStart: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DataAccess.shared.startSessionTimeout(isStart: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
         self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Private Func
    
    private func setStatusBarBackgroundColor(color: UIColor) {
        if isMiniWebView { return }
        visualStatusBarViw = UIView(frame: UIApplication.shared.statusBarFrame)
        visualStatusBarViw.isHidden = true
        visualStatusBarViw.backgroundColor = color
        webKit?.addSubview(visualStatusBarViw)
    }
    
    private func setupBaseWebview() {
        
        self.view.layoutIfNeeded()
        
        self.webKit = BaseWebView(withFrame: view.bounds, andURL: self.urlStr, isBounce: self.isBounce, isMini: self.isMiniWebView)
        self.webKit?.backgroundColor = isMiniWebView ? UIColor.black.withAlphaComponent(0.3) : UIColor.white
        self.webKit?.delegate = self
        self.webKit?.param = self.param
        self.webKit?.addOnHeader = self.addOnHeader
        self.view.addSubview(webKit!)
        
        let webBackgroundColor = UIColor.clear
        
        if !isMiniWebView {
            
            var bottomPadding : CGFloat = 0.0
            
            if #available(iOS 11.0, *) {
                bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            } else {
                // Fallback on earlier versions
            }
            
            let bFrame = CGRect(x: 0, y: self.view.bounds.height - bottomPadding, width: self.view.bounds.width, height: bottomPadding)
            let bView = UIView(frame: bFrame)
            bView.backgroundColor = webBackgroundColor
            webKit?.addSubview(bView)
        }
        
        // MARK: - Safhone remove kak function
//        setStatusBarBackgroundColor(color: webBackgroundColor)
        /// **** start load url if not empty ****
        if !urlStr.isEmpty {
            self.webKit?.loadURL()
        }
        setupAnimationBodyView()
    }
    
    private func setupAnimationBodyView() {
        if isMiniWebView {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.webKit?.transform = CGAffineTransform.identity.scaledBy(x: 0.99, y: 0.99)
            }) { (finished) in
                UIView.animate(withDuration: 0.2, animations: {
                    self.webKit?.transform = CGAffineTransform.identity.scaledBy(x: 1.01, y: 1.01)
                }) { (finished) in
                    UIView.animate(withDuration: 0.3, animations: {
                        self.webKit?.transform = CGAffineTransform.identity
                    })
                }
            }
        }
    }
    
    @objc private func popToPreviousViewController() {
        
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showURLBySafari(_ paramDic: [String : Any]?) {
        
        //사파리로 Url open
        let urlString = paramDic?["_url"] as? String ?? ""
        
        if let url : URL = URL.init(string: urlString) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    /*
     * 1:           title
     * 2: <         title
     * 3:           title       x
     * 4:           title       alarm_icon
     * 5:           title       setting_icon
     * 9:           no_title
     * 10:<         title       x
     * 11:x         title
     */
    private func webNavigationBarStyle(ad: Dictionary<String, Any>?) {
        let menuTitle = ad?["_title"] as? String ?? ""
        let menuType = ad?["_type"] as? String ?? ""
        
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        switch menuType {
            
        case "1":
            
            self.navigationItem.title = menuTitle
            let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self.navigationController, action: nil)
            self.navigationItem.leftBarButtonItem = backButton
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        case "2":
            
            self.navigationItem.title = menuTitle
            
            let leftButton = UIButton(frame: CGRect(x: 20,y: 0, width: 50, height: 33))
            leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            leftButton.contentHorizontalAlignment = .left
            leftButton.setImage(UIImage(named: "head_arrow_ico"), for: UIControl.State())
            leftButton.addTarget(self, action: #selector(navigationBarButtonActionHandler(sender:)), for: .touchUpInside)
            
            let leftBarButton = UIBarButtonItem(customView: leftButton)
            self.navigationItem.leftBarButtonItem = leftBarButton
            self.navigationController?.navigationBar.barTintColor   = UIColor(hexString: "FFFFFF")//UIColor(hexString: "216CB6")
            self.navigationController?.navigationBar.isTranslucent  = true
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage    = UIImage()
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "080829"), NSAttributedString.Key.font: UIFont(name: "Inter-Medium", size: 15)!]
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        case "3":
            
            self.navigationItem.title = menuTitle
            let rightbutton = UIButton(type: .custom)
            rightbutton.contentHorizontalAlignment = .right
            rightbutton.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
            rightbutton.setImage(UIImage(named: "head_close_white"), for: .normal)
            rightbutton.addTarget(self, action: #selector(navigationBarButtonActionHandler(sender:)), for: .touchUpInside)
            
            let rightBarButton = UIBarButtonItem(customView: rightbutton)
            self.navigationItem.rightBarButtonItem = rightBarButton
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        case "10":
            self.navigationItem.title = menuTitle
            let leftButton = UIButton(frame: CGRect(x: 0,y: 0, width: 50, height: 33))
            leftButton.contentHorizontalAlignment = .left
            leftButton.setImage(UIImage(named: "head_close_blue"), for: UIControl.State())
            leftButton.tag = 0
            leftButton.addTarget(self, action: #selector(navigationBarButtonActionHandler(sender:)), for: .touchUpInside)
            
            let rightButton = UIButton(frame: CGRect(x: 0,y: 0, width: 50, height: 33))
            rightButton.contentHorizontalAlignment = .right
            rightButton.setImage(UIImage(named: "head_close_blue"), for: UIControl.State())
            rightButton.tag = 1
            rightButton.addTarget(self, action: #selector(navigationBarButtonActionHandler(sender:)), for: .touchUpInside)
            
            let leftBarButton = UIBarButtonItem(customView: leftButton)
            let rightBarButton = UIBarButtonItem(customView: rightButton)
            self.navigationItem.leftBarButtonItem = leftBarButton
            self.navigationItem.rightBarButtonItem = rightBarButton
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        case "11":
            
            self.navigationItem.title = menuTitle
            let leftButton = UIButton(frame: CGRect(x: 0,y: 0, width: 50, height: 33))
            leftButton.contentHorizontalAlignment = .left
            leftButton.setImage(UIImage(named: "head_close_white"), for: UIControl.State())
            leftButton.addTarget(self, action: #selector(navigationBarButtonActionHandler(sender:)), for: .touchUpInside)
            
            let leftBarButton = UIBarButtonItem(customView: leftButton)
            self.navigationItem.leftBarButtonItem = leftBarButton
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        default: break
        }
    }
    
    // 상단 Title변경
    @objc private func navigationBarButtonActionHandler(sender: UIButton) {
        
        switch webKitType {
        case .ASP:
            switch sender.tag {
            case 0:
//                self.webKit.webViewDidClose(WKWebView())
//                self.webKit.loadURL()
                if webKit.webview.canGoBack {
                    webKit.webview.goBack()
                }else {
                   popToPreviousViewController()
                }
            default:
                self.webKit.webViewDidClose(WKWebView())
                popToPreviousViewController()
            }
        default:
            if webKit.webview.canGoBack {
                if urlStr.contains(finishedUrl ?? "") {
                    popToPreviousViewController()
                }
                else {
                    webKit.webview.goBack()
                }
            }else {
               popToPreviousViewController()
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - BaseWebViewDelegate in Swift

extension WebKitViewController: BaseWebViewDelegate {
    
    func navigationAction(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            
            let urlScheme = navigationAction.request.url?.scheme ?? ""
            
            if(isItunesURL(url.absoluteString)) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
                decisionHandler(.cancel)
            }
            else if urlScheme != "http" && urlScheme != "https" {
                if urlScheme.contains("about") {
                    decisionHandler(.allow)
                }
                else if urlScheme.contains("wabooks") {
                    let urlStr = navigationAction.request.url?.absoluteString
                    
                    let actionCodeStr = urlStr?.replace(of: "wabooks://", with: "") ?? ""
                    let actionCodeDic = (actionCodeStr.removingPercentEncoding)?.toDictionary
  
                    if actionCodeDic?["_action_code"] as? String ?? "" == "SIGNIN_PAGE" {
                        decisionHandler(.cancel)
                        let actionData = actionCodeDic?["_action_data"] as? [String:String?] 
                        Shared.user_id = actionData?["user_id"] as? String ?? ""
                        popToPreviousViewController()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    decisionHandler(.cancel)
                }
            }
            else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    
    func baseWebViewResponseCode(actionCode: ActionCode, actionData: [String : Any]?) {
        
        switch actionCode {
        case .empty: break
        case .ac_1000: LoadingView.show()
        case .ac_1001: LoadingView.delayBeforeHide()
        case .ac_1002: popToPreviousViewController()
        case .ac_1004: break
        case .ac_2000: break
        case .ac_2001: self.popToPreviousViewController()
        case .ac_2002: break
        case .ac_2003: break
        case .ac_2004: break
        case .ac_2101: break
        case .ac_2102: break
        case .ac_2103: break
        case .ac_2104: break
        case .ac_2105: break
        case .ac_2106: break
        case .ac_2107: break
        case .ac_2108: break
        case .ac_2109: break
        case .ac_2110: break
        case .ac_2111: break
        case .ac_3000: break
        case .ac_3001: break
        case .ac_3002: break
        case .ac_4000: break
        case .ac_4001: break
        case .ac_4002: break
        case .ac_5000: showURLBySafari(actionData)
        case .ac_5001: break
        case .ac_5002: break
        case .ac_5109: break
        case .ac_6000: break
        case .ac_6001: break
        case .ac_6002: break
        case .ac_6003: break
        case .ac_7000: break
        case .ac_8000: break
        case .ac_12001: break
        case .ac_12002: break
        case .ac_12003: break
        case .ac_12004: break
        case .ac_MYBIZ_CLOSE_WEBVIEW: popToPreviousViewController()
        case .ac_OPEN_FULLSCREEN_WEBVIEW: break
        case .ac_CLOSE_WEBVIEW:
            self.popToPreviousViewController()
        default:
            break
        }
    }
    
    func baseWebViewDidFinishLoad(webView: WKWebView, title: String) {
        titleString = title
        finishedUrl = webView.url?.absoluteString
        // MARK: - Safhone remove kak function
//        if !isMiniWebView { visualStatusBarViw.isHidden = false }
    }
    
    func showAlertMessageError(messageError: String) {
        
        LoadingView.delayBeforeHide(seconds:  0.3) { (_) in
            if messageError.isEmpty {
                
            }
            else {
                
                self.showCustomAlert(titlte: "notice".localized, message: messageError) {
                    self.popToPreviousViewController()
                }
            }
        }
    }
    
    func showAlertMessage(message: String, handler: (() -> Void)?) {
        
        LoadingView.delayBeforeHide(seconds: 0.3) { (status) in
            
            self.showCustomAlert(titlte: "notice".localized, message: message) {
                handler?()
            }
        }
    }
    
    func showAlertPromptMessage(message: String) {
        self.showCustomAlert(titlte: message, message: message) {
            
        }
    }
    
    func showAlertConfirmMessage(message: String, handler: ((Bool) -> Void)?) {
        self.alertYesNo(title: message, message: message, nobtn: "cancel".localized, yesbtn: "comfirm".localized) { (status) in
            handler?(status)
        }
    }
    
}

extension UIViewController {
    
    func isMatch(_ urlString: String, _ pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
        return result.count > 0
    }
    
    func isItunesURL(_ urlString: String) -> Bool {
        return isMatch(urlString, "\\/\\/itunes\\.apple\\.com\\/")  || isMatch(urlString, "\\/\\/apps\\.apple\\.com\\/")
    }
    
    func showCustomAlert(titlte: String, message: String, greyBtn: String = "comfirm".localized, completion: @escaping Completion) {
        self.customAlert(type: .CONFIRM_ALERT, image: "badge_failed", title: titlte , message: message, redTitle: "", greyTitle: greyBtn) { (isRedPress) in
            completion()
        }
    }
    
}

// MARK: - BaseWebKitDelegate in Objective-C

extension WebKitViewController: BaseWebKitDelegate {
    
    private func setupObjective_CBaseWebView() {
        
        self.view.layoutIfNeeded()
        
        wkBaseWebView = WkBaseWebView(frame: view.bounds, withUrl: self.urlStr)
        wkBaseWebView.baseDelegate = self
        wkBaseWebView.param = self.param
        
        self.view.addSubview(wkBaseWebView)
        
        wkBaseWebView.loadRequest()
    }
    
    func baseWebKitResponseCode(_ actionCode: String, actionData actionCodeData: [AnyHashable : Any]) {
        
        let type = ActionCode(rawValue: actionCode)
        
        switch type {
        case .empty: break
        case .ac_1000: LoadingView.show()
        case .ac_1001: LoadingView.delayBeforeHide()
        case .ac_1002: popToPreviousViewController()
        case .ac_1004: break
        case .ac_2000: break
        case .ac_2001: self.popToPreviousViewController()
        case .ac_2002: break
        case .ac_2003: break
        case .ac_2004: break
        case .ac_2101: break
        case .ac_2102: break
        case .ac_2103: break
        case .ac_2104: break
        case .ac_2105: break
        case .ac_2106: break
        case .ac_2107: break
        case .ac_2108: break
        case .ac_2109: break
        case .ac_2110: break
        case .ac_2111: break
        case .ac_3000: break
        case .ac_3001: break
        case .ac_3002: break
        case .ac_4000: break
        case .ac_4001: break
        case .ac_4002: break
        case .ac_5000: break//showURLBySafari(actionData)
        case .ac_5001: break
        case .ac_5002: break
        case .ac_5109: break
        case .ac_6000: break
        case .ac_6001: break
        case .ac_6002: break
        case .ac_6003: break
        case .ac_7000: break
        case .ac_8000: break
        case .ac_12001: break
        case .ac_12002: break
        case .ac_12003: break
        case .ac_12004: break
        case .ac_MYBIZ_CLOSE_WEBVIEW: popToPreviousViewController()
        case .ac_OPEN_FULLSCREEN_WEBVIEW: break
        case .ac_CLOSE_WEBVIEW:
            self.popToPreviousViewController()
        default:
            break
        }
    }
    
    func baseWebKitDidFinishLoading(_ baseWebView: WKWebView, title webTitle: String) {
        titleString = webTitle
        finishedUrl = baseWebView.url?.absoluteString
        
        LoadingView.hide()
    }
    
    func baseWebKitAlertMessage(_ message: String, completion handler: (() -> Void)? = nil) {
        LoadingView.delayBeforeHide(seconds: 0.3) { (status) in
            
            self.showCustomAlert(titlte: "", message: message) {
                handler?()
            }
        }
    }
    
    func baseWebKitAlertMessageError(_ messageError: String) {
        
        LoadingView.delayBeforeHide(seconds:  0.3) { (_) in
            if messageError.isEmpty {
                
            }
            else {
//               self.alert(title: "", message: messageError, okbtn: "confirm".localized) {
//                    self.popToPreviousViewController()
//                }
                
                self.showCustomAlert(titlte: "", message: messageError) {
                    self.popToPreviousViewController()
                }
            }
        }
    }
    
    func baseWebKitAlertPromptMessage(_ message: String) {
        self.showCustomAlert(titlte: "", message: message) {
        }
    }
    
    func baseWebKitAlertConfirmMessage(_ message: String, completion handler: ((Bool) -> Void)? = nil) {
        self.alertYesNo(title: "", message: message, nobtn: "cancel".localized, yesbtn: "comfirm".localized) { (status) in
            handler?(status)
        }
    }

    func baseWebKitnavigationAction(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, handler decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            
            let urlScheme = navigationAction.request.url?.scheme ?? ""
            
            if(isItunesURL(url.absoluteString)) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
                decisionHandler(.cancel)
            }
            else if urlScheme != "http" && urlScheme != "https" {
                if urlScheme.contains("about") {
                    decisionHandler(.allow)
                }
                else {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    decisionHandler(.cancel)
                }
            }
            else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func baseWebKitdidStartProvisionalNavigation(_ webView: WKWebView, wknavigation navigation: WKNavigation) {
        
        if let urlSt = webView.url?.absoluteString, !urlSt.contains("webtoapp:") && !urlSt.contains("wapi") {
            LoadingView.show()
        }
    }
    
}
