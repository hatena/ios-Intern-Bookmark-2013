//
//  IBKMLoginViewController.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "IBKMLoginViewController.h"

#import "AFNetworkActivityIndicatorManager.h"

#import "UIAlertView+NSError.h"

#import "IBKMInternBookmarkAPIClient.h"

@interface IBKMLoginViewController ()

@end

@implementation IBKMLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // ログインページを開く
    NSURLRequest *request = [NSURLRequest requestWithURL:[IBKMInternBookmarkAPIClient loginURL]];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    if (error.code != NSURLErrorCancelled) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithError:error];
        [alertView addButtonWithTitle:@"OK"];
        [alertView show];
    }
}

@end
