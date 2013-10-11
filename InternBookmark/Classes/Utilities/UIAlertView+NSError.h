//
//  UIAlertView+NSError.h
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/18.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import <UIKit/UIKit.h>

/** `UIAlertView` を `NSError` で初期化するためのカテゴリ */
@interface UIAlertView (NSError)

/** `NSError` を表示する `UIAlertView`

`UIAlertView` を消すためのボタンなどは必要に応じて追加しなければならない.

@param error 表示したい `NSError`.
@return `UIAlertView` インスタンス.
*/
- (id)initWithError:(NSError *)error;

@end
