//
//  IBKMBookmarkManager.h
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IBKMBookmark;

/** ブックマーク管理オブジェクト */
@interface IBKMBookmarkManager : NSObject

/** ブックマーク配列

`IBKMBookmark` の `NSArray`.
*/
@property (nonatomic, readonly) NSMutableArray *bookmarks;

///---------------------------------------------------------------------------------------
/// @name 管理オブジェクトを得る
///---------------------------------------------------------------------------------------

/** シングルトンの管理オブジェクトを得る

@return `IBKMBookmarkManager`.
*/
+ (IBKMBookmarkManager *)sharedManager;

///---------------------------------------------------------------------------------------
/// @name ブックマークを保存する
///---------------------------------------------------------------------------------------

/** ブックマークを保存する

@param bookmark `IBKMBookmark` オブジェクト.
@param block 完了時に呼び出される blocks.
*/
- (void)saveBookmark:(IBKMBookmark *)bookmark withBlock:(void (^)(NSError *error))block;

///---------------------------------------------------------------------------------------
/// @name ブックマークを取得する
///---------------------------------------------------------------------------------------

/** `bookmarks` を再読込する

いまある全ての `bookmarks` は破棄され, 新しく読み込み直す.

@param block 完了時に呼び出される blocks.
*/
- (void)reloadBookmarksWithBlock:(void (^)(NSError *error))block;

/** `bookmarks` の続きを読み込む

@param block 完了時に呼び出される blocks.
*/
- (void)loadMoreBookmarksWithBlock:(void (^)(NSError *error))block;

@end
