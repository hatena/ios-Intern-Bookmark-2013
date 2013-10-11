//
//  IBKMBookmark.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "IBKMBookmark.h"

#import "NSDateFormatter+MySQL.h"

#import "IBKMEntry.h"
#import "IBKMUser.h"

@implementation IBKMBookmark

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{
    // bookmarkID
    NSNumber *bookmarkID;
    NSNumber *bookmarkID_ = json[@"bookmark_id"];
    if ([bookmarkID_ isKindOfClass:[NSNumber class]]) {
        bookmarkID = bookmarkID_;
    }

    // comment
    NSString *comment;
    NSString *comment_ = json[@"comment"];
    if ([comment_ isKindOfClass:[NSString class]]) {
        comment = comment_;
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

    // entry
    IBKMEntry *entry;
    NSDictionary *entryDictionary = json[@"entry"];
    if ([entryDictionary isKindOfClass:[NSDictionary class]]) {
        entry = [[IBKMEntry alloc] initWithJSONDictionary:entryDictionary];
    }

    // user
    IBKMUser *user;
    NSDictionary *userDictionary = json[@"user"];
    if ([entryDictionary isKindOfClass:[NSDictionary class]]) {
        user = [[IBKMUser alloc] initWithJSONDictionary:userDictionary];
    }

    return [self initWithBookmarkID:bookmarkID comment:comment entry:entry user:user created:created updated:updated];
}

- (instancetype)initWithBookmarkID:(NSNumber *)bookmarkID comment:(NSString *)comment entry:(IBKMEntry *)entry user:(IBKMUser *)user created:(NSDate *)created updated:(NSDate *)updated
{
    self = [super init];
    if (self) {
        _bookmarkID = bookmarkID;
        _comment = comment;
        _entry = entry;
        _user = user;
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
    // bookmark_id が等しくないときは同一じゃない.
    if (![[self bookmarkID] isEqualToNumber:[other bookmarkID]])
        return NO;

    return YES;
}

- (NSUInteger)hash
{
    return [self.bookmarkID hash];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.bookmarkID=%@", self.bookmarkID];
    [description appendFormat:@", self.comment=%@", self.comment];
    [description appendFormat:@", self.entry=%@", self.entry];
    [description appendFormat:@", self.user=%@", self.user];
    [description appendFormat:@", self.created=%@", self.created];
    [description appendFormat:@", self.updated=%@", self.updated];
    [description appendString:@">"];
    return description;
}

@end

