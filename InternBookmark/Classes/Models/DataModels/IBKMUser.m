//
//  IBKMUser.m
//  InternBookmark
//
//  Created by Hiroki Kato on 2013/07/16.
//  Copyright (c) 2013年 株式会社はてな. All rights reserved.
//

#import "IBKMUser.h"

#import "NSDateFormatter+MySQL.h"

@implementation IBKMUser

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{
    // userID
    NSNumber *userID;
    NSNumber *userID_ = json[@"user_id"];
    if ([userID_ isKindOfClass:[NSNumber class]]) {
        userID = userID_;
    }

    // name
    NSString *name;
    NSString *name_ = json[@"name"];
    if ([name_ isKindOfClass:[NSString class]]) {
        name = name_;
    }

    NSDateFormatter *dateFormatter = [NSDateFormatter MySQLDateFormatter];

    // created
    NSDate *created;
    NSString *createdString = json[@"created"];
    if ([createdString isKindOfClass:[NSString class]]) {
        created = [dateFormatter dateFromString:createdString];
    }

    return [self initWithUserID:userID name:name created:created];
}

- (instancetype)initWithUserID:(NSNumber *)userID name:(NSString *)name created:(NSDate *)created
{
    self = [super init];
    if (self) {
        _userID = userID;
        _name = name;
        _created = created;
    }

    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    // user_id が等しくないときは同一じゃない
    if (![[self userID] isEqualToNumber:[other userID]])
        return NO;

    return YES;
}

- (NSUInteger)hash
{
    return [self.userID hash];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.userID=%@", self.userID];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.created=%@", self.created];
    [description appendString:@">"];
    return description;
}

@end
