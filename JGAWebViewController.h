//
//  JGAWebViewController.h
//  HMS
//
//  Created by John Grant on 12-06-19.
//  Copyright (c) 2012 Healthcare Made Simple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGAWebViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *defaultTitle;

@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *stopButton;
@property (strong, nonatomic) UIBarButtonItem *refreshButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;

@property (nonatomic, assign) BOOL showToolbar;
@property (nonatomic, assign) BOOL showAddressBar;

+(id)modalWebViewControllerWithUrl:(NSURL *)url defaultTitle:(NSString *)defaultTitle showsToolbar:(BOOL)showsToolbar showsAddressBar:(BOOL)showsAddressBar completionBlock:(void(^)(void))completionBlock;

+(id)webViewControllerWithUrl:(NSURL *)url defaultTitle:(NSString *)defaultTitle;
+(id)webViewControllerWithUrlString:(NSString *)urlString defaultTitle:(NSString *)defaultTitle;

@end
