//
//  JGAWebViewController.m
//  HMS
//
//  Created by John Grant on 12-06-19.
//  Copyright (c) 2012 Healthcare Made Simple. All rights reserved.
//

#import "JGAWebViewController.h"

@interface JGAWebViewController ()

@end

@implementation JGAWebViewController
@synthesize webView = _webView;
@synthesize textField = _textField;
@synthesize url = _url;
@synthesize backButton = _backButton;
@synthesize stopButton = _stopButton;
@synthesize refreshButton = _refreshButton;
@synthesize forwardButton = _forwardButton;
@synthesize defaultTitle = _defaultTitle;

static NSString *_httpPrefix = @"http://";

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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUpToolbar];
    [self toggleToolbarButtons];
    [self loadUrl];
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
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorAlert show];
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
