//
//  IBKMBookmarkViewController.h
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IBKMBookmark;

/** 個別ブックマーク画面 */
@interface IBKMBookmarkViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate>

/** URL 欄 */
@property (weak, nonatomic) IBOutlet UITextField *URLField;

/** コメント 欄 */
@property (weak, nonatomic) IBOutlet UITextField *commentField;

/** WebView */
@property (weak, nonatomic) IBOutlet UIWebView *webView;

/** キーボードの高さを表現する `NSLayoutConstraint` */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;

/** 表示している `IBKMBookmark` */
@property (nonatomic) IBKMBookmark *bookmark;

/** 表示中のページをブックマークする

@param sender sender
*/
- (IBAction)save:(id)sender;

@end
