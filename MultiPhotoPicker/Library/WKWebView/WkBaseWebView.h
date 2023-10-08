//
//  BaseWebView.h
//
//  Created by eggtarte on 2015. 12. 3..
//  Copyright © 2015년 eggtarte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol BaseWebKitDelegate;

typedef void (^JavascriptCompleteBlock) (id _Nullable result, NSError * _Nullable error);

@interface WkBaseWebView : UIView <NSURLSessionTaskDelegate>

@property (nonatomic) id <BaseWebKitDelegate> _Nullable baseDelegate;

@property (nonatomic, strong) NSString * _Nullable param;
@property (nonatomic, strong) NSURL * _Nullable activeURL;

- (instancetype _Nonnull)initWithFrame:(CGRect)frame withUrl:(NSString *_Nullable)urlString;
- (void)stringByEvaluatingJavaScriptFromString:(NSString *_Nullable)script completeBlock:(JavascriptCompleteBlock _Nullable )completeBlock;
- (void)loadRequest;
- (void)loadHTMLString:(NSString *_Nullable)htmlString baseUrl:(NSURL *_Nullable)url;

@end


@protocol BaseWebKitDelegate <NSObject>

@required

- (void)baseWebKitResponseCode:(NSString * _Nonnull)actionCode actionData:(NSDictionary *_Nonnull)actionCodeData;
- (void)baseWebKitDidFinishLoading:(WKWebView * _Nonnull)baseWebView title:(NSString * _Nonnull)webTitle;
- (void)baseWebKitAlertMessage:(NSString * _Nonnull)message completion:(void (^_Nullable) (void))handler;
- (void)baseWebKitAlertMessageError:(NSString * _Nonnull)messageError;
- (void)baseWebKitAlertPromptMessage:(NSString * _Nonnull)message;
- (void)baseWebKitAlertConfirmMessage:(NSString * _Nonnull)message completion:(void (^ _Nullable) (BOOL))handler;
- (void)baseWebKitnavigationAction:(WKWebView * _Nonnull)webView decidePolicyFor:(WKNavigationAction * _Nonnull)navigationAction handler:(void (^_Nonnull) (WKNavigationActionPolicy))decisionHandler;
- (void)baseWebKitdidStartProvisionalNavigation:(WKWebView * _Nonnull)webView wknavigation:(WKNavigation * _Nonnull)navigation;

@end
