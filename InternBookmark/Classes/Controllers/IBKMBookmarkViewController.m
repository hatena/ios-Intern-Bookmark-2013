//
//  IBKMBookmarkViewController.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "IBKMBookmarkViewController.h"

#import "AFNetworkActivityIndicatorManager.h"

#import "UIAlertView+NSError.h"

#import "IBKMBookmarkManager.h"
#import "IBKMBookmark.h"
#import "IBKMEntry.h"

@interface IBKMBookmarkViewController ()

@end

@implementation IBKMBookmarkViewController

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

    self.title = self.bookmark.entry.title;

    self.URLField.text = [self.bookmark.entry.URL absoluteString];
    self.commentField.text = self.bookmark.comment;

    // ブックマークされているページを開く.
    NSURLRequest *request = [NSURLRequest requestWithURL:self.bookmark.entry.URL];
    [self.webView loadRequest:request];

    // キーボードが出てきたりしたときの通知を受け取る.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* キーボードの高さが変わったとき呼び出される

このメソッドの中でキーボードの高さに合わせていろいろ調整する.
*/
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect screenBounds = [UIScreen mainScreen].bounds; // 画面の bounds.
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]; // 変化後のキーボードの frame.
    double animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]; // キーボードの高さが変わるアニメーションの時間.

    // 端末が縦向き (portrait) か横向き (landscape) か.
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);

    // キーボードの高さは画面の縦の長さからキーボードのy座標を引き算することで得られるはず.
    // ただし landscape のときはちょっと変わる.
    CGFloat keyboardHeight = isPortrait ?
            (screenBounds.size.height - keyboardFrame.origin.y) :
            (screenBounds.size.width - keyboardFrame.origin.x);
    // キーボードの高さを表す NSLayoutConstraint にキーボードの高さを設定する.
    // こうしておけば Auto Layout が働いていい感じに調整してくれる.
    self.keyboardHeight.constant = -keyboardHeight;

    // レイアウトを変える必要がある.
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UITextFieldDelegate

/* TextField の編集が終わったとき */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.URLField) {
        // URL の TextField の編集が終わったとき, WebView を新しい URL で読み込む.
        NSURL *URL = [NSURL URLWithString:textField.text];

        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
}

/* キーボードの return キーを押したとき */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // キーボードを隠す.
    [textField resignFirstResponder];
    // 改行はできない.
    return NO;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // `URLField` の値を読み込もうとしているページの URL に更新する.
    self.URLField.text = [request.URL absoluteString];

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

    // `URLField` の値を読み込んだページの URL に更新する.
    self.URLField.text = [webView.request.URL absoluteString];
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

#pragma mark - IBAction

- (IBAction)save:(id)sender
{
    NSURL *URL = [NSURL URLWithString:self.URLField.text];
    if (!URL) {
        // URL が存在しなかったり, URL として取り扱えないとき, この段階で処理をやめる.
        return;
    }
    NSString *comment = self.commentField.text;

    // entry と bookmark を作る
    IBKMEntry *entry = [[IBKMEntry alloc] initWithEntryID:nil URL:URL title:nil created:nil updated:nil];
    IBKMBookmark *bookmark = [[IBKMBookmark alloc] initWithBookmarkID:nil comment:comment entry:entry user:nil created:nil updated:nil];

    [[IBKMBookmarkManager sharedManager] saveBookmark:bookmark
                                            withBlock:^(NSError *error) {
                                                if (error) {
                                                    NSLog(@"error = %@", error);
                                                }
                                                else {
                                                    // 保存が成功したら画面を戻す.
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }
                                            }];
}

/* ログイン画面から戻ったとき呼ばれる */
- (IBAction)closeLoginSegue:(UIStoryboardSegue *)segue
{
}

@end
