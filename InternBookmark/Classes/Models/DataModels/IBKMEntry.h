//
//  IBKMEntry.h
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import <Foundation/Foundation.h>

/** エントリーオブジェクト */
@interface IBKMEntry : NSObject

/** entry_id */
@property (nonatomic, readonly) NSNumber *entryID;

/** url */
@property (nonatomic, readonly) NSURL *URL;

/** title */
@property (nonatomic, readonly) NSString *title;

/** created */
@property (nonatomic, readonly) NSDate *created;

/** updated */
@property (nonatomic, readonly) NSDate *updated;

/** `JSON` 辞書から `IBKMEntry` を初期化する

@param json `JSON` 辞書.
@return `IBKMEntry`.
*/
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** `IBKMEntry` 初期化

@param entryID entry_id.
@param URL url.
@param title title.
@param created created.
@param updated updated.
@return `IBKMEntry`.
*/
- (instancetype)initWithEntryID:(NSNumber *)entryID URL:(NSURL *)URL title:(NSString *)title created:(NSDate *)created updated:(NSDate *)updated;

@end
