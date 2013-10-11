//
//  IBKMUser.h
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import <Foundation/Foundation.h>

/** ユーザーオブジェクト */
@interface IBKMUser : NSObject

/** user_id */
@property (nonatomic, readonly) NSNumber *userID;

/** name */
@property (nonatomic, readonly) NSString *name;

/** created */
@property (nonatomic, readonly) NSDate *created;

/** `JSON` 辞書から `IBKMUser` を初期化する

@param json `JSON` 辞書.
@return `IBKMUser`.
*/
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** `IBKMUser` 初期化

@param userID user_id.
@param name name.
@param created created.
@return `IBKMUser`.
*/
- (instancetype)initWithUserID:(NSNumber *)userID name:(NSString *)name created:(NSDate *)created;

@end
