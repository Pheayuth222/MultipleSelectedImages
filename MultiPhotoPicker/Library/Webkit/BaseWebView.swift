//
//  BaseWebView.swift
//  ZeroPay
//
//  Created by iMac007 on 12/08/2019.
//  Copyright © 2019 Webcash. All rights reserved.
//

import UIKit
import WebKit

enum ActionCode : String {
    case empty = ""
    case ac_OPEN_WEB = "OPEN_WEBVIEW"
    case ac_1000 = "1000"  // 로딩바 시작
    case ac_1001 = "1001"  // 로딩바 종료
    case ac_1002 = "1002"  // 로그인 화면 이동
    case ac_1004 = "1004"  // 로그인 화면 이동 (session timeout)
    case ac_2000 = "2000"  // 로그인 화면이동
    case ac_2001 = "2001"  // id심기 || Approval -> Start Progress Bar
    case ac_2002 = "2002"  // id가져오기 || Approval -> Exit Progress Bar
    case ac_2003 = "2003"  // 자동로그인 여부 저장
    case ac_2004 = "2004"  // 푸쉬아이디 요청
    case ac_2101 = "2101"  // Approval -> Show authProcessingButton
    case ac_2102 = "2102"  // Approval -> Hide authProcessingButton
    case ac_2103 = "2103"  // Approval -> Close | Title | InfoButton
    case ac_2104 = "2104"  // Approval -> Hide InfoButton
    case ac_2105 = "2105"  // Approval -> Show processingButton
    case ac_2106 = "2106"  // Approval -> Hide processingButton
    case ac_2107 = "2107"  // Approval -> Show cancelButton
    case ac_2108 = "2108"  // Approval -> Hide cancelButton
    case ac_2109 = "2109"  // Approval -> Show draftPageButton
    case ac_2110 = "2110"  // Approval -> Hide draftPageButton
    case ac_2111 = "2111"  // Approval -> Show navTitle & searchButton
    case ac_3000 = "3000"  // 앱종료
    case ac_3001 = "3001"  // 팝업없이 앱종료
    case ac_3002 = "3002"  // 푸쉬뱃지 카운트 변경
    case ac_4000 = "4000"  // 상단 Title변경
    case ac_4001 = "4001"  // Alert창 호출
    case ac_4002 = "4002"  // Confirm창 호출
    case ac_5000 = "5000"  // 외부 브라우져 호출
    case ac_5001 = "5001"  // 거래확인서 발급
    case ac_5002 = "5002"  // 거래확인서 발급
    case ac_5005 = "5005"  // Logout
    case ac_5109 = "5109"  // 외부 브라우져 호출
    case ac_6000 = "6000"  // 메인화면으로 이동
    case ac_6001 = "6001"  // 설정화면으로 이동
    case ac_6002 = "6002"  // 웹뷰를 종료
    case ac_7000 = "7000"  // 보안키패드화면 호출
    case ac_8000 = "8000"  // 가맹점 앱 호출
    case ac_12001 = "12001" // 제로페이 포인트 플랫폼 WEB View 회원가입 호출
    case ac_12002 = "12002" // 제로페이 포인트 플랫폼 WEB View Main 호출
    case ac_12003 = "12003" // 제로페이 포인트 이체인증(구매/환불) CallBack 함수 호출
    case ac_12004 = "12004" // 제로페이포인트 app 사용자인증 CallBack 함수 호출
    
    //new on 2019.10.04
    case ac_6003 = "6003"  // QR/BAR코드 스캔화면 이동
    
    //new on 2020.02.28
    case ac_MYBIZ_CLOSE_WEBVIEW = "MYBIZ_CLOSE_WEBVIEW" // Kill VC
    
    // Approval App 2020.02.28
    case ac_OPEN_FULLSCREEN_WEBVIEW = "OPEN_FULLSCREEN_WEBVIEW" // Approval
    
    // ImageWebView From Approval App 2020.03.17
    case ac_CLOSE_WEBVIEW = "CLOSE_WEBVIEW"
}

protocol BaseWebViewDelegate {
    func baseWebViewResponseCode(actionCode : ActionCode,actionData : [String : Any]?)
    func baseWebViewDidFinishLoad(webView: WKWebView, title : String)
    func showAlertMessage(message: String, handler: (() -> Void)?)
    func showAlertMessageError(messageError: String)
    func showAlertPromptMessage(message: String)
    func showAlertConfirmMessage(message: String, handler: ((Bool) -> Void)?)
    func navigationAction(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
}

class BaseWebView : UIView {
    var delegate        : BaseWebViewDelegate?
    var webview         : WKCookieWebView!
    var urlString       : String! = ""
    var param           : String?
    var addOnHeader     : Dictionary<String, String>?
    var isMiniWebView   : Bool = false
    
    ///메인으로 사용중인 웹뷰
    var createWebView   : WKCookieWebView?
    
    //MARK: ------- private components ------------
    private var isBounceWeb : Bool  = false
    private var individualUserAgent = "WABOOKS_APP"
    private var isCustomLoadingView = false
    
    private var activityIndicator   : UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    var isTimeOut   = true
    
    //MARK: - initialize
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Initialize BaseWebView
    ///
    /// - Parameters:
    ///   - frame: frame for webview
    ///   - urlStr: url to load
    init(withFrame frame: CGRect, andURL urlStr : String, isBounce: Bool = true, isMini: Bool = false, isCustomLoading: Bool = false) {
        var _frame = frame
        if isMini {
            _frame = CGRect(x: 35.0, y: 75.0, width: frame.size.width - 70.0, height: frame.size.height - 150.0)
        }
        super.init(frame: _frame)
        self.backgroundColor      = UIColor(red: 245, green: 245, blue: 245)
        self.urlString            = urlStr
        self.isMiniWebView        = isMini
        self.isCustomLoadingView  = isCustomLoading
        
        if self.isCustomLoadingView {
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.activityIndicator)
            
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        self.initilizeWebKit(withFrame: self.bounds, isBounce: isBounce)
    }
    
    /// Initialize WKWebView
    private func initilizeWebKit(withFrame frame: CGRect, isBounce: Bool = true) {
        self.isBounceWeb    = isBounce
        
        let preferences     = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true // For open new window over current WebView
        
        
        // webview content page to fit (JS helper) need to use in WKWebViewConfiguration
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        
        let conf            = WKWebViewConfiguration()
        conf.userContentController = wkUController
        conf.preferences    = preferences
        
        webview = WKCookieWebView(frame: frame, configuration: conf, useRedirectCookieHandling: true)
        webview.navigationDelegate  = self
        webview.uiDelegate          = self
        webview.allowsBackForwardNavigationGestures = true
        webview.allowsLinkPreview   = false
        //        webview.autoresizingMask    = [.flexibleWidth, .flexibleHeight]
        webview.contentMode         = .scaleAspectFill
        
        //- config User-Agent
        webview.evaluateJavaScript("navigator.userAgent") { (result, error) in
            if let customUserAgent = result as? String {
                self.webview.customUserAgent = customUserAgent + " \(self.individualUserAgent)"
            }
        }
        
        self.addSubview(webview)
        webview.scrollView.bouncesZoom = false
    }
    
    /// URL 로드
    func loadURL() {
        let url = URL(string: urlString)
        guard let urlToLoad = url else {
            self.delegate?.showAlertMessageError(messageError: "error_occurred_during_process".localized)
            return
        }
        var urlRequest = URLRequest(url: urlToLoad)
        //- setup header
        let Authorization = "\(Shared.R002_DATA?.TOKEN_TYPE ?? "") \(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"

        urlRequest.addValue(Authorization,                  forHTTPHeaderField: "Authorization")
        urlRequest.addValue(APIKey.XAPPVERSION.rawValue,    forHTTPHeaderField: "X-App-Version")
        urlRequest.addValue("utf-8",                        forHTTPHeaderField: "charset")
        urlRequest.addValue(Shared.language.rawValue,       forHTTPHeaderField: "Accept-Language")
        
        var jSESSIONID = ""
        if let cookies = HTTPCookieStorage.shared.cookies {
            cookies.forEach({
                if $0.name == "JSESSIONID" {
                    jSESSIONID += "JSESSIONID=\($0.value);"
                }
            })
            
            let str = "\(jSESSIONID)LANG=\(Shared.language.rawValue.uppercased())"
            urlRequest.addValue(str, forHTTPHeaderField: "Cookie")
        }

        // WebView Error if put content type = application/json
//        urlRequest.addValue("application/json",             forHTTPHeaderField: "content-type")

        webview.scrollView.bounces = true
        webview.scrollView.isScrollEnabled = true
        
        //- setup param
        if let myParam = self.param {
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = myParam.data(using: .utf8)
        }
        _ = webview.load(urlRequest)
        
        hideShowLoading(isShow: true)
    }
    
    // convert dic to string
    func convertDicToJSONString(_ dic: [String:Any]) -> String? {
        do {
            let data : Data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions(rawValue: 0))
            let outputSt = String(data: data, encoding: .utf8)
            return outputSt
        } catch let error as NSError {
#if DEBUG
            print(error.localizedDescription)
#endif
        } catch let randomError {
#if DEBUG
            print(randomError.localizedDescription)
#endif
        }
        return nil
    }
    
    /// 액션코드 조절함
    ///
    /// - Parameters:
    ///   - actionCode: 액션 코드
    ///   - actionData: 액션 데이터
    private func handleActionCode(actionCode:String,actionData : [String: Any]?) {
        if self.delegate != nil {
            
            let actionCD = ActionCode(rawValue: actionCode) ?? .empty
#if DEBUG
            print("::::: Action Code :::::")
            print(actionCode)
            print("::::: Action Data :::::")
            print(actionData ?? "")
#endif
            self.delegate?.baseWebViewResponseCode(actionCode: actionCD, actionData: actionData)
        }
    }
    
    fileprivate func checkActionCode(jsonData:String,completion: @escaping (String,[String:Any]?) -> Void) {
        if jsonData.lowercased().contains("iwebactionba") {
            var actionDic: [String: Any]?
            
            let compJson = jsonData.components(separatedBy: ":")
            let scheme = compJson.first ?? ""
            let jsonString = jsonData.replacingOccurrences(of: "\(scheme):", with: "")
            actionDic = jsonString.removingPercentEncoding?.toDictionary
            
            if let actionDic = actionDic {
                guard let actionCodes = (actionDic["_action_code"] as? String)?.components(separatedBy: "|") else {
                    return
                }
                if let actionData = actionDic["_action_data"] as? [String:Any] {
                    for actionCode in actionCodes {
                        completion(actionCode,actionData)
                    }
                }else {
                    for actionCode in actionCodes {
                        completion(actionCode,nil)
                    }
                }
            }
        }
    }
    
    private func handleErrorMessage(error: Error) {
        var errorMessage: String = ""
        let errorCode = (error as NSError).code
        
        switch errorCode {
            //-1001 " The request time out
        case -1009, -1005,-1001: // -1005: connection lost
            errorMessage = "connection_is_unstable_please_try_again_later".localized
        default:
            break
            //            errorMessage = error.localizedDescription
        }
        self.delegate?.showAlertMessageError(messageError: errorMessage)
    }
    
    private func hideShowLoading(isShow: Bool) {
        DispatchQueue.main.async {
            if self.isCustomLoadingView {
                self.bringSubviewToFront(self.activityIndicator)
                isShow ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            }
            else {
                isShow ? LoadingView.show() : LoadingView.hide()
            }
        }
        
    }
}


extension BaseWebView: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
#if DEBUG
        print("Error loading URL: ", error)
#endif
        handleErrorMessage(error: error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
#if DEBUG
        print("didFailProvisionalNavigation", error.localizedDescription,(error as NSError).code)
#endif
        handleErrorMessage(error: error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
#if DEBUG
        print("............................Webkit did finish loading............................")
#endif
        
        if let pageTitle = webView.title {
            if self.delegate != nil {
                self.delegate?.baseWebViewDidFinishLoad(webView: webView, title: pageTitle)
            }
        }
        self.isTimeOut = false
        if delegate != nil {
            hideShowLoading(isShow: false)
        }
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // restart session timeout counter
        //        DispatchQueue.main.async {
        //            NotificationCenter.default.post(name: Notification.Name(rawValue: kSessionTimeRenewalNoti), object: nil)
        //        }
        
        if let urlSt = webView.url?.absoluteString, !urlSt.contains("webtoapp:") && !urlSt.contains("wapi") {
            hideShowLoading(isShow: true)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
#if DEBUG
        print("............................Webkit decide policy............................")
        print(navigationAction.request.url?.absoluteString ?? "")
#endif
        
        if navigationAction.request.url?.scheme?.lowercased().contains("iwebactionba") ?? false {
            self.checkActionCode(jsonData: navigationAction.request.url?.absoluteString ?? "") { (actionCode, actionData) in
                self.handleActionCode(actionCode: actionCode, actionData: actionData)
            }
            decisionHandler(.cancel)
        }
        else {
            self.delegate?.navigationAction(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
#if DEBUG
        print("............................Webkit navigation response............................")
#endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(60.0)) {
            if self.isTimeOut {
                self.delegate?.showAlertMessageError(messageError: "connection_is_unstable_please_try_again_later".localized)
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
#if DEBUG
        print("............................Webkit run java script............................")
        print(message)
        print("..........................End Webkit run java script..........................")
#endif
        
        if message.lowercased().contains("iwebactionba") { // handle with action code
            self.checkActionCode(jsonData: message) { (actionCode, actionData) in
                self.handleActionCode(actionCode: actionCode, actionData: actionData)
            }
            completionHandler()
        }else {
            var outputMessage = message
            if outputMessage.contains("JEX") { outputMessage = "error_occurred_during_process".localized }
            self.delegate?.showAlertMessage(message: outputMessage, handler: {
                completionHandler()
            })
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
#if DEBUG
        print("............................Webkit confirm panel............................")
        print(message)
        print("..........................End Webkit confirm panel..........................")
#endif
        
        
        if !message.lowercased().contains("iwebactionba") {
            var outputMessage = message
            if outputMessage.contains("JEX") { outputMessage = "error_occurred_during_process".localized }
            
            self.delegate?.showAlertConfirmMessage(message: outputMessage, handler: { (status) in
                completionHandler(status)
            })
        } else {
            completionHandler(true)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
#if DEBUG
        print("............................Webkit prompt panel............................")
        print(prompt)
        print("..........................End Webkit prompt panel..........................")
#endif
        
        if prompt.lowercased().contains("iwebactionba") {
            self.checkActionCode(jsonData: prompt) { (actionCode, actionData) in
                self.handleActionCode(actionCode: actionCode, actionData: actionData)
            }
        }
        
        completionHandler(nil)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
#if DEBUG
        print("createWebViewWith \(webView)")
#endif
        
        //파라미터로 받은 configuration
        createWebView = WKCookieWebView(frame: webView.frame, configuration: configuration, useRedirectCookieHandling: true)
        createWebView!.navigationDelegate = self
        createWebView!.uiDelegate = self
        createWebView!.evaluateJavaScript("navigator.userAgent") { (result, error) in
            if let userAgent = result as? String {
                let customUserAgent = userAgent
                self.createWebView!.customUserAgent = customUserAgent + " \(self.individualUserAgent)"
                
            }
        }
        
        //오토레이아웃 처리
        createWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(createWebView!)
        
        return createWebView!
    }
    
    func webViewDidClose(_ webView: WKWebView) {
#if DEBUG
        print("webViewDidClose \(webView)")
#endif
        
        if webView == createWebView {
            createWebView?.removeFromSuperview()
            createWebView = nil
        }
    }
}
