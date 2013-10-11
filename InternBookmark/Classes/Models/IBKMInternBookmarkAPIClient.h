//
//  IBKMInternBookmarkAPIClient.h
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "AFHTTPClient.h"

@protocol IBKMInternBookmarkAPIClientDelegate;

/** Intern::Bookmark サーバーとの API を介したやりとりを抽象化する */
@interface IBKMInternBookmarkAPIClient : AFHTTPClient

/** delegate オブジェクト */
@property (nonatomic, weak) id <NSObject, IBKMInternBookmarkAPIClientDelegate> delegate;

///---------------------------------------------------------------------------------------
/// @name 便利クラスメソッド
///---------------------------------------------------------------------------------------

+ (NSURL *)loginURL;

///---------------------------------------------------------------------------------------
/// @name インスタンスを得る
///---------------------------------------------------------------------------------------

+ (instancetype)sharedClient;

///---------------------------------------------------------------------------------------
/// @name API とのやりとり
///---------------------------------------------------------------------------------------

/** ブックマーク一覧を取得する

@param perPage ページ当たりのアイテム個数.
@param page ページ番号.
@param block 完了時に呼び出される blocks.
*/
- (void)getBookmarksWithPerPage:(NSUInteger)perPage page:(NSUInteger)page completion:(void (^)(NSDictionary *results, NSError *error))block;

/** ブックマークを投稿する

同一の URL に対する投稿は編集扱いとなる.

@param URL ブックマークする URL.
@param comment ブックマークコメント.
@param block 完了時に呼び出される blocks.
*/
- (void)postBookmarkWithURL:(NSURL *)URL comment:(NSString *)comment comletion:(void (^)(NSDictionary *results, NSError *error))block;

@end

/** `IBKMInternBookmarkAPIClient` の delegate */
@protocol IBKMInternBookmarkAPIClientDelegate

/** ログインが必要な際に呼び出される

@param client `IBKMInternBookmarkAPIClient` オブジェクト.
*/
- (void)APIClientNeedsLogin:(IBKMInternBookmarkAPIClient *)client;

@end