//
//  NSDateFormatter+MySQL.h
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/18.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import <Foundation/Foundation.h>

/** MySQL から出力されるフォーマットの日時を取り扱うためのカテゴリ */
@interface NSDateFormatter (MySQL)

/** MySQL から出力されるフォーマットの日時を取り扱うためのフォーマッターを作る

@return `NSDateFormatter`.
*/
+ (instancetype)MySQLDateFormatter;

@end
