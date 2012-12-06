//
//  JGAWebViewController.m
//  HMS
//
//  Created by John Grant on 12-06-19.
//  Copyright (c) 2012 Healthcare Made Simple. All rights reserved.
//

#import "JGAWebViewController.h"

@interface JGAWebViewController ()

@property (nonatomic, copy) void(^completionBlock)(void);
@end

@implementation JGAWebViewController
{
    BOOL _isDisappearing;
}

static NSString *_httpPrefix = @"http://";

+(id)modalWebViewControllerWithUrl:(NSURL *)url defaultTitle:(NSString *)defaultTitle showsToolbar:(BOOL)showsToolbar showsAddressBar:(BOOL)showsAddressBar completionBlock:(void(^)(void))completionBlock
{
    JGAWebViewController *viewController = [JGAWebViewController webViewControllerWithUrl:url defaultTitle:defaultTitle];
    viewController.showAddressBar = showsAddressBar;
    viewController.showToolbar = showsToolbar;
    viewController.completionBlock = completionBlock;
    [viewController addCloseButtonToNavBar];
    return viewController;
}

+(id)webViewControllerWithUrl:(NSURL *)url defaultTitle:(NSString *)defaultTitle
{
    JGAWebViewController *viewController = [[JGAWebViewController alloc] initWithNibName:@"JGAWebViewController" bundle:nil];
    viewController.url = url;
    viewController.defaultTitle = defaultTitle;
    return viewController;
}

+(id)webViewControllerWithUrlString:(NSString *)urlString defaultTitle:(NSString *)defaultTitle
{
    NSURL *url = [JGAWebViewController urlWithString:urlString];
    return [JGAWebViewController webViewControllerWithUrl:url defaultTitle:defaultTitle];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _showToolbar = YES;
        _showAddressBar = YES;
    }
    return self;
}

+ (NSURL *)urlWithString:(NSString *)string
{
    if (![[string substringToIndex:4] isEqualToString:@"http"]) {
        string = [_httpPrefix stringByAppendingString:string];
    }
    
    return [NSURL URLWithString:string];
}

- (void)addCloseButtonToNavBar
{
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonPressed:)];
    self.navigationItem.leftBarButtonItem = closeButton;
}

- (void)closeButtonPressed:(id)sender
{
    if(_completionBlock){
        _completionBlock();
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_showAddressBar) {
        _webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [self.view bringSubviewToFront:_webView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:!_showToolbar animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUpToolbar];
    [self toggleToolbarButtons];
    [self loadUrl];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isDisappearing = YES;
    [_webView stopLoading];
}

- (void)loadUrl
{
    if (_url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_url];
        [_webView loadRequest:request];
    }
}

- (void)setUpToolbar
{
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"WebBackButton"]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self action:@selector(backButtonPressed:)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"WebForwardButton"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self action:@selector(forwardButtonPressed:)];
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                       target:self action:@selector(refreshButtonPressed:)];
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                    target:self action:@selector(stopButtonPressed:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil action:nil];
    NSArray *items = [NSArray arrayWithObjects:_backButton,space, _stopButton, space,_refreshButton,space, _forwardButton, nil];
    [self setToolbarItems: items animated:YES];
}

- (void)viewDidUnload
{
    [_webView stopLoading];
    [self setWebView:nil];
    [self setTextField:nil];
    [self setBackButton:nil];
    [self setStopButton:nil];
    [self setRefreshButton:nil];
    [self setForwardButton:nil];
    _webView.delegate = nil;
    _textField.delegate = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

- (void)toggleToolbarButtons
{
    self.stopButton.enabled = _webView.isLoading;
    self.refreshButton.enabled = !_webView.isLoading;
    self.backButton.enabled = _webView.canGoBack;
    self.forwardButton.enabled = _webView.canGoForward;
}

#pragma mark - UIWebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.navigationItem.title = @"Loading...";
    self.textField.text = [_url absoluteString];
    [self toggleToolbarButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.navigationItem.title = _defaultTitle;
    [self toggleToolbarButtons];
    
    if (!_isDisappearing){
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.title = _defaultTitle;
    [self toggleToolbarButtons];
}
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.url = [JGAWebViewController urlWithString:textField.text];
    [self loadUrl];
    return YES;
}

#pragma mark - Actions
- (void)backButtonPressed:(id)sender
{
    if ([_webView canGoBack]) {
        [_webView stopLoading];
        [_webView goBack];
    }
}
- (void)forwardButtonPressed:(id)sender
{
    if ([_webView canGoForward]) {
        [_webView stopLoading];
        [_webView goForward];
    }
}
- (void)stopButtonPressed:(id)sender
{
    [_webView stopLoading];
}
- (void)refreshButtonPressed:(id)sender
{
    [_webView reload];
}



@end
