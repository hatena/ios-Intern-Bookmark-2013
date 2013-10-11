//
//  IBKMBookmark.h
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IBKMEntry;
@class IBKMUser;

/** ブックマークオブジェクト */
@interface IBKMBookmark : NSObject

/** bookmark_id */
@property (nonatomic, readonly) NSNumber *bookmarkID;

/** comment */
@property (nonatomic, readonly) NSString *comment;

/** entry */
@property (nonatomic, readonly) IBKMEntry *entry;

/** user */
@property (nonatomic, readonly) IBKMUser *user;

/** created */
@property (nonatomic, readonly) NSDate *created;

/** updated */
@property (nonatomic, readonly) NSDate *updated;

/** `JSON` 辞書から `IBKMBookmark` を初期化する

@param json `JSON` 辞書.
@return `IBKMBookmark`.
*/
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** `IBKMBookmark` 初期化

@param bookmarkID bookmark_id.
@param comment comment.
@param entry `IBKMEntry`.
@param user `IBKMUser`.
@param created created.
@param updated updated.
@return `IBKMBookmark`.
*/
- (instancetype)initWithBookmarkID:(NSNumber *)bookmarkID comment:(NSString *)comment entry:(IBKMEntry *)entry user:(IBKMUser *)user created:(NSDate *)created updated:(NSDate *)updated;

@end
