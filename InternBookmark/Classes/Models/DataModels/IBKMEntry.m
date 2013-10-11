//
//  IBKMEntry.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "IBKMEntry.h"

#import "NSDateFormatter+MySQL.h"

@implementation IBKMEntry

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{
    // entryID
    NSNumber *entryID;
    NSNumber *entryID_ = json[@"entry_id"];
    if ([entryID_ isKindOfClass:[NSNumber class]]) {
        entryID = entryID_;
    }

    // URL
    NSURL *URL;
    NSString *URLString = json[@"url"];
    if ([URLString isKindOfClass:[NSString class]]) {
        URL = [NSURL URLWithString:URLString];
    }

    // title
    NSString *title;
    NSString *title_ = json[@"title"];
    if ([title_ isKindOfClass:[NSString class]]) {
        title = title_;
    }

    NSDateFormatter *dateFormatter = [NSDateFormatter MySQLDateFormatter];

    // created
    NSDate *created;
    NSString *createdString = json[@"created"];
    if ([createdString isKindOfClass:[NSString class]]) {
        created = [dateFormatter dateFromString:createdString];
    }

    // updated
    NSDate *updated;
    NSString *updatedString = json[@"updated"];
    if ([updatedString isKindOfClass:[NSString class]]) {
        updated = [dateFormatter dateFromString:updatedString];
    }

    return [self initWithEntryID:entryID URL:URL title:title created:created updated:updated];
}

- (instancetype)initWithEntryID:(NSNumber *)entryID URL:(NSURL *)URL title:(NSString *)title created:(NSDate *)created updated:(NSDate *)updated
{
    self = [super init];
    if (self) {
        _entryID = entryID;
        _URL = URL;
        _title = title;
        _created = created;
        _updated = updated;
    }

    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    // entry_id が等しくないときは同一じゃない.
    if (![[self entryID] isEqualToNumber:[other entryID]])
        return NO;

    return YES;
}

- (NSUInteger)hash
{
    return [self.entryID hash];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.entryID=%@", self.entryID];
    [description appendFormat:@", self.URL=%@", self.URL];
    [description appendFormat:@", self.title=%@", self.title];
    [description appendFormat:@", self.created=%@", self.created];
    [description appendFormat:@", self.updated=%@", self.updated];
    [description appendString:@">"];
    return description;
}

@end
