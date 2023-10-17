//
//  BaseWebView.m
//
//  Created by eggtarte on 2015. 12. 3..
//  Copyright © 2015년 eggtarte. All rights reserved.
//

#import "WkBaseWebView.h"

@interface WkBaseWebView()<WKUIDelegate, WKNavigationDelegate> {
    WKWebView *_wkWebView;
    
    WKWebView *createWebView;
}

@end

@implementation WkBaseWebView

- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSString *)urlString {
    self = [super initWithFrame:frame];
    
    if (urlString) {
        _activeURL = [[NSURL alloc] initWithString:urlString];
    }
    
    WKPreferences *preferences = [[WKPreferences alloc] init];
    [preferences setJavaScriptCanOpenWindowsAutomatically:YES];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config setPreferences:preferences];
    
    _wkWebView = [[WKWebView alloc] initWithFrame:[self bounds] configuration:config];
    
    [_wkWebView setNavigationDelegate:self];
    [_wkWebView setUIDelegate:self];
    [[_wkWebView scrollView] setBouncesZoom:NO];
    [_wkWebView setAllowsBackForwardNavigationGestures:YES];
    [_wkWebView setAllowsLinkPreview:NO];
    
    [_wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSString *result = (NSString *)obj;
        if (result) {
            [self->_wkWebView setCustomUserAgent:result];
        }
    }];
    
    [self addSubview:_wkWebView];
    return self;
}

- (void)loadRequest {
    
    if (_activeURL) {
        
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:_activeURL];
        
        if (_param) {
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[_param dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
        
        [self requestWithCookieHandling:urlRequest completion:^(NSURLRequest * _Nullable paramRequest, NSURLResponse * _Nullable paramResponse, NSData * _Nullable paramData, NSError * _Nullable paramError) {
            
            if (paramError) {
                [self->_wkWebView loadRequest:paramRequest];
            }
            else {
                
                [self syncCookiesInJS:urlRequest];
                
                if (paramData) {
                    [self webViewLoad:paramData urlReponse:paramResponse];
                }
                else {
                    
                    [self->_wkWebView loadRequest:paramRequest];
                    
                }
            }
        }];
    }
    
    [[_wkWebView scrollView] setBounces:NO];
}

- (void)loadHTMLString:(NSString *)htmlString baseUrl:(NSURL *)url {
    if (_wkWebView) {
        [_wkWebView loadHTMLString:htmlString baseURL:url];
    }
}

- (WKNavigation *)webViewLoad:(NSData *)data urlReponse:(NSURLResponse *)response {
    if ([response URL]) {
        
        NSString *encode = [response textEncodingName];
        NSString *mime = [response MIMEType];
        
        return [_wkWebView loadData:data MIMEType:mime characterEncodingName:encode baseURL:[response URL]];
        
    }
    else {
        return NULL;
    }
}

-(void)requestWithCookieHandling:(NSMutableURLRequest *)request completion:(void (^)(NSURLRequest * _Nullable paramRequest, NSURLResponse * _Nullable paramResponse, NSData * _Nullable paramData, NSError * _Nullable paramError))completionHandler {
    
    NSURLSessionConfiguration * sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig delegate:self delegateQueue:nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == NULL) {
                if (response) {
                    
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    NSInteger *code = [httpResponse statusCode];
                    
                    if (code == 200) {
                        // for code 200 return data to load data directly
                        completionHandler(request, response, data, error);
                    }
                    else if (code >= 300 && code < 400) {
                        NSString *location = [[httpResponse allHeaderFields] objectForKey:@"Location"];
                        NSURL *redirectUrl = [[NSURL alloc] initWithString:location];
                        
                        if (redirectUrl) {
                            NSURLRequest *newRequest = [[NSURLRequest alloc] initWithURL:redirectUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
                            completionHandler(newRequest,response,data,error);
                            return;
                        }
                        
                    }
                    
                }
            }
            completionHandler(request,response,data,error);
        });
        
    }];
    [task resume];
    
}



// sync HTTPCookieStorage cookies to URLRequest
//-(void)syncCookies:(NSMutableURLRequest *)request sessionTask:(NSURLSessionTask *)task completion:(void (^)(NSURLRequest * _Nullable cookieRequest))completionHandler {
//
//    NSMutableURLRequest *newRequest = request;
//
//    if (task) {
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] getCookiesForTask:task completionHandler:^(NSArray<NSHTTPCookie *> * _Nullable cookies) {
//            if (cookies) {
//
//                NSDictionary *cookieDict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
//                NSString *cookieStr = [cookieDict objectForKey:@"Cookie"];
//
//                NSDictionary *header = [newRequest allHTTPHeaderFields];
//                NSMutableDictionary *headerDic = [[NSMutableDictionary alloc] initWithDictionary:header];
//                [headerDic setObject:cookieStr forKey:@"Cookie"];
//
//                [newRequest setAllHTTPHeaderFields:headerDic];
//            }
//            completionHandler(newRequest);
//        }];
//    }
//    else {
//        NSURL *url = [newRequest URL];
//
//        NSDictionary *cookieDict = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url]];
//        NSString *cookieStr = [cookieDict objectForKey: @"Cookie"];
//
//        NSDictionary *header = [newRequest allHTTPHeaderFields];
//        NSMutableDictionary *headerDic = [[NSMutableDictionary alloc] initWithDictionary:header];
//        [headerDic setObject:cookieStr forKey:@"Cookie"];
//
//        [newRequest setAllHTTPHeaderFields:headerDic];
//
//        completionHandler(newRequest);
//    }
//
//}

- (void)syncCookiesInJS:(NSMutableURLRequest *) request {
    if ([request URL]) {
        
        NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[request URL]];
        if (cookies) {
            NSString * script = [self jsCookiesString:cookies];
            WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [[[_wkWebView configuration] userContentController]addUserScript:cookieScript];
        }
    }
    else {
        
        NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        
        if (cookies) {
            NSString * script = [self jsCookiesString:cookies];
            WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [[[_wkWebView configuration] userContentController]addUserScript:cookieScript];
        }
    }
    
    [[[_wkWebView configuration] userContentController] addUserScript:[self userScript]];
}


- (NSString *)jsCookiesString:(NSArray<NSHTTPCookie *> *) cookies {
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
    
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [result appendFormat: @"document.cookie='%@=%@; domain=%@; path=%@; ",obj.name,obj.value,obj.domain,obj.path];
        
        NSDate *date = obj.expiresDate;
        [result appendFormat: @"expires=%@; ",[dateFormatter stringFromDate:date]];
        
        if (obj.isSecure) {
            [result appendFormat: @"secure; "];
        }
        [result appendFormat: @"'; "];
        
    }];
    
    return result;
}

- (WKUserScript *)userScript {

    NSString *viewPortScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, shrink-to-fit=YES'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);";

    return [[WKUserScript alloc] initWithSource:viewPortScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
}

- (void)handlerErrorMessage:(NSError *)error {
    
    NSString *errorMessage = @"";
    
    switch ([error code]) {
        case -1009:
            errorMessage = @"처리중 오류가 발생하였습니다.";
        default:
            break;
    }
    
    if ([self.baseDelegate respondsToSelector:@selector(baseWebKitAlertMessageError:)]) {
        [self.baseDelegate baseWebKitAlertMessageError:errorMessage];
    }
    
}

- (void)handleActionCode:(NSString *)actionCode actionCode:(NSDictionary *)actionData {
    
    NSLog(@" %@ parsingActionCode from %@ ",actionCode, actionData);
    
    if ([self.baseDelegate respondsToSelector:@selector(baseWebKitResponseCode:actionData:)]) {
        [self.baseDelegate baseWebKitResponseCode:actionCode actionData:actionData];
    }
}

- (void)checkActionCode:(NSString *)jsonData completion:(void (^) (NSString *, NSDictionary *))handler {
    if ([[jsonData lowercaseString] containsString:@"iwebaction"]) {
        
        NSArray *compJson = [jsonData componentsSeparatedByString:@":"];
        NSString *scheme = [compJson firstObject];
        NSString *jsonString = [jsonData stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:",scheme] withString:@""];
        
        jsonString = [jsonString stringByRemovingPercentEncoding];
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *actionDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (actionDic) {
            NSString *code = [actionDic objectForKey:@"_action_code"];
            NSDictionary *actionData = [actionDic objectForKey:@"_action_data"];
            
            NSArray *actionCodes = [code componentsSeparatedByString:@"|"];
            
            if (actionData) {
                [actionCodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    handler(code, actionData);
                }];
            }
            else {
                [actionCodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    handler(code, NULL);
                }];
            }
        }
        
    }
}

- (void)stringByEvaluatingJavaScriptFromString:(NSString *)script completeBlock:(JavascriptCompleteBlock)completeBlock {
    __block NSString *returnResult = [NSString string];
    
    if (_wkWebView) {
        returnResult = @"";
        [_wkWebView evaluateJavaScript:script completionHandler:^(id result, NSError * wkWebViewError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result, wkWebViewError);
            });
            
        }];
    }
}

#pragma mark -
#pragma mark WKWebView Delegate

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    #if DEBUG
    NSLog(@"didFailNavigation : %@", error);
    #endif
    [self handlerErrorMessage:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    #if DEBUG
    NSLog(@"didFailProvisionalNavigation : %@", error);
    #endif
    [self handlerErrorMessage:error];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    #if DEBUG
    NSLog(@"didFinishNavigation : %@", webView);
    #endif
    
    if ([webView title]) {
        if ([self.baseDelegate respondsToSelector:@selector(baseWebKitDidFinishLoading:title:)]) {
            [self.baseDelegate baseWebKitDidFinishLoading:webView title:[webView title]];
        }
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if ([self.baseDelegate respondsToSelector:@selector(baseWebKitdidStartProvisionalNavigation:wknavigation:)]) {
        [self.baseDelegate baseWebKitdidStartProvisionalNavigation:webView wknavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    #if DEBUG
    NSLog(@"............................Webkit decide policy............................");
    NSLog(@"%@", navigationAction.request.URL.absoluteString);
    #endif
    
    if ([[[[[navigationAction request] URL] scheme] lowercaseString] containsString:@"iwebaction"]) {
        [self checkActionCode:[[[navigationAction request] URL] absoluteString] completion:^(NSString * actionCode, NSDictionary *actionData) {
            [self handleActionCode:actionCode actionCode:actionData];
        }];
        decisionHandler(NO);
    }
    else {
        if ([self.baseDelegate respondsToSelector:@selector(baseWebKitnavigationAction:decidePolicyFor:handler:)]) {
            [self.baseDelegate baseWebKitnavigationAction:webView decidePolicyFor:navigationAction handler:decisionHandler];
        }
        else {
            decisionHandler(YES);
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    #if DEBUG
    NSLog(@"............................Webkit navigation response............................");
    #endif
    decisionHandler(YES);
}


#pragma mark -
#pragma mark WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    #if DEBUG
    NSLog(@"............................Webkit run java script............................");
    NSLog(@"%@", message);
    NSLog(@"............................End Webkit run java script............................");
    #endif
    
    if ([[message lowercaseString] containsString:@"iwebaction"]) {
        [self checkActionCode:message completion:^(NSString * actionCode, NSDictionary *actionData) {
            [self handleActionCode:actionCode actionCode:actionData];
        }];
        completionHandler();
    }
    else {
        
        NSString *outputMessage = message;
        
        if ([message containsString: @"JEX"]) {
            outputMessage = @"처리중 오류가 발생하였습니다.";
        }
        if ([self.baseDelegate respondsToSelector:@selector(baseWebKitAlertMessage:completion:)]) {
            [self.baseDelegate baseWebKitAlertMessage:outputMessage completion:^{
                completionHandler();
            }];
        }
        else {
            completionHandler();
        }
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    #if DEBUG
    NSLog(@"............................Webkit confirm panel............................");
    NSLog(@"%@", message);
    NSLog(@"............................End Webkit confirm panel............................");
    #endif
    
    if ([[message lowercaseString] containsString:@"iwebaction"]) {
        completionHandler(YES);
    }
    else {
        
        NSString *outputMessage = message;
        
        if ([message containsString: @"JEX"]) {
            outputMessage = @"처리중 오류가 발생하였습니다.";
        }
        
        if ([self.baseDelegate respondsToSelector:@selector(baseWebKitAlertConfirmMessage:completion:)]) {
            [self.baseDelegate baseWebKitAlertConfirmMessage:outputMessage completion:^(BOOL status) {
                completionHandler(status);
            }];
        }
        else {
            completionHandler(YES);
        }
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    #if DEBUG
    NSLog(@"............................Webkit confirm panel............................");
    NSLog(@"%@", prompt);
    NSLog(@"............................End Webkit confirm panel............................");
    #endif
    
    
    if ([[prompt lowercaseString] containsString:@"iwebaction"]) {
        [self checkActionCode:prompt completion:^(NSString *actionCode, NSDictionary *actiondata) {
            [self handleActionCode:actionCode actionCode:actiondata];
        }];
    }
    
    completionHandler(NULL);
    
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    #if DEBUG
    NSLog(@"createWebViewWith %@", webView);
    #endif
    
    createWebView = [[WKWebView alloc] initWithFrame:[webView frame] configuration:configuration];
    [createWebView setNavigationDelegate:self];
    [createWebView setUIDelegate:self];
    [createWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSString *result = (NSString *)obj;
        if (result) {
            [self->createWebView setCustomUserAgent:result];
        }
    }];
    
    createWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self addSubview:createWebView];
    
    return createWebView;
}

- (void)webViewDidClose:(WKWebView *)webView {
    
    #if DEBUG
    NSLog(@"webViewDidClose %@", webView);
    #endif
    
    if (webView == createWebView) {
        [createWebView removeFromSuperview];
        createWebView = NULL;
    }
    
}

@end
