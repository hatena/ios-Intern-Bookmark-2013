//
//  NSDateFormatter+MySQL.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/18.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "NSDateFormatter+MySQL.h"

@implementation NSDateFormatter (MySQL)

+ (instancetype)MySQLDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return formatter;
}

@end
